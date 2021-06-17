# Elm+Node Pub/Sub example
## Licence: Apache 2.0

## EXPERIMENTAL
This is a sample of how to use Cloud Pub/Sub from the pure functional web app language Elm, using the Node Pub/Sub libraries. It's basically just to see if I could, so please do not base your product on this! :)

This is UNOFFICIAL and EXPERIMENTAL, and not recommended at this time. _Caveat emptor!_

This is part of a Medium blog post: https://feywind.medium.com/using-cloud-pub-sub-on-node-js-from-elm-2a769731c097

## What is it?

Elm is a language that was designed for pure functional programming when working with client side web apps. My read of it is that it's derived strongly from Haskell, but it transpiles to a JavaScript app.

One thing led to another, and here is an Elm app that runs on Node and communicates with Pub/Sub in an event-driven way. I am definitely not holding this up as a paragon of Elm excellence (I just started learning it a few days ago), but it's neat that it does something.

## Why?

Elm modules are easily shareable across both client and server, because they are guaranteed side-effect free and type safe. The peace of mind that provides would be useful in a server-side tool. You could also e.g. share Elm types across the client and server when building an Elm web app.

## Running it

You'll need to use `npm install -g` to get both `elm` and `elm-node` commands. `npm install` will set up your project, then, and `npm run run` runs it. You will also need a Pub/Sub emulator running unless you tweak the defaults in `src/index.js`.

## Design thoughts

The optimal place to put the barrier between Elm and JavaScript is a bit wibbly-wobbly, and will probably depend a great deal on what you want to achieve. The one I chose here is basically to let Elm logic receive messages and decide how to respond and ack. It's a really simplistic thing, but maybe it'll be something to help unstick you if you're playing around with Elm.
