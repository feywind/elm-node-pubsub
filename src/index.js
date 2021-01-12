// For real work, I think you'd want to use TypeScript or the like.
// But I'm just keeping this simple.
const PubSub = require('@google-cloud/pubsub');

module.exports = async Elm => {
  // Get our Pub/Sub set up first.
  const pubsubClient = new PubSub.PubSub({
    apiEndpoint: "http://localhost:8085",
    project: "test-project"
  });

  // Create or find the test topic.
  const topicName = "test-topic";
  let topic;
  try {
    [topic] = await pubsubClient.createTopic(topicName);
  } catch (e) {
    topic = pubsubClient.topic(topicName);
  }

  // Create or find the test subscription.
  const subName = "test-sub";
  let sub;
  try {
    [sub] = await pubsubClient.createSubscription(topic, subName);
  } catch (e) {
    sub = pubsubClient.subscription(subName);
  }

  // Message passing to and from Elm should be minimal, so we'll
  // track outstanding message objects on this side.
  const messages = new Map();

  const app = Elm.Main.init();

  app.ports.log && app.ports.log.subscribe(console.log);

  app.ports.publish && app.ports.publish.subscribe(opts => {
    console.log(`publishing: ${opts.message}`);
    topic.publish(Buffer.from(opts.message));
  });

  app.ports.ack && app.ports.ack.subscribe(opts => {
    console.log(`acking: ${opts}`);
    const msg = messages.get(opts);
    messages.delete(opts);
    msg.ack();
  });

  app.ports.exit && app.ports.exit.subscribe(opts => process.exit(opts));

  app.ports.receive && sub.on('message', msg => {
    console.log(`received in JS: ${msg.id} : ${msg.data}`);
    const id = `${msg.id}`;
    messages.set(id, msg);
    const response = {
      id,
      data: msg.data.toString()
    };
    app.ports.receive.send(response);
  });
};
