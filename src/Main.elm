port module Main exposing
    (main
    , log
    , publish
    , receive
    , ack
    , exit)

import Platform exposing (worker)

-- This is our JavaScript bridge interface.
type alias MessageToSend = String
type alias MessageReceived =
    { id : String
    , data : String }

port log : String -> Cmd msg

port publish : { message : MessageToSend } -> Cmd msg
port receive : ( MessageReceived -> msg ) -> Sub msg
port ack : String -> Cmd msg

port exit : Int -> Cmd msg

-- Elm side model.

type alias Model =
    { messageCount : Int }

type Msg =
    Received MessageReceived

main : Program () Model Msg
main =
    worker
        { init = init
        , subscriptions = subscriptions
        , update = update
        }

-- For init, we'll just kick off the first publish and init the model.
init : () -> ( Model, Cmd cmd )
init conn =
    ( { messageCount = 0 }
    , Cmd.batch [
        log "Elm starting Pub/Sub Elm test",
        publish { message = "Yay, this is a test to get us going!" }
    ] )

-- Listen to incoming messages from the JavaScript side.
subscriptions : Model -> Sub Msg
subscriptions _ =
    receive Received

-- The only update we need to process is for incoming messages.
-- This just increments a counter and bails after 5 messages, as well
-- as acking the ones we receive.
update : Msg -> Model -> ( Model, Cmd cmd )
update msg model =
    case msg of
        Received message -> (
            { model | messageCount = model.messageCount + 1 },
            if model.messageCount >= 5 then
                Cmd.batch [
                    log ("Elm received 5 messages, bailing!"),
                    exit 0 ]
            else
                Cmd.batch [
                    log ("Elm received: " ++ message.data),
                    ack message.id,
                    publish { message = "A followup!" }
                ] )
