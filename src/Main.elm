port module Main exposing
    (main
    , log
    , publish
    , receive
    , ack)

import Platform exposing (worker)
import List exposing (drop, take, length)

-- This is our JavaScript bridge interface.
type alias MessageToSend = String
type alias MessageReceived =
    { id : String
    , data : String }

port log : String -> Cmd msg

port publish : { message : MessageToSend } -> Cmd msg
port receive : ( MessageReceived -> msg ) -> Sub msg
port ack : String -> Cmd msg


-- Elm side model.

sampleText : String
sampleText = "Mary had a little lamb whose fleece was white as snow."
sampleArray : List String
sampleArray = String.split " " sampleText

type alias Model =
    { toSend : List String
    , receivedMessage : List String }

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
init _ =
    ( { toSend = drop 1 sampleArray
      , receivedMessage = [] }
    , Cmd.batch [
        log "Elm starting Pub/Sub Elm test",
        publish { message = String.join "" (take 1 sampleArray) }
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
        Received message ->
            let
                newReceived = model.receivedMessage ++ [ message.data ]
                soFar = String.join " " newReceived
            in
            (
                { model
                | toSend = drop 1 model.toSend
                , receivedMessage = newReceived },
                Cmd.batch [
                    log ("Elm received so far: '" ++ soFar ++ "'"),
                    ack message.id,
                    if (length model.toSend) > 0 then
                        publish { message = String.join "" (take 1 model.toSend) }
                    else
                        Cmd.none
                ]
            )
