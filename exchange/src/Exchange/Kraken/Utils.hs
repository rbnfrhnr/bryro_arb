module Exchange.Kraken.Utils
  ( parseKrakenMessage
  , subscribeToDepthBook
  ) where

import qualified Control.Concurrent.Chan            as C
import qualified Control.Concurrent.MVar            as MVar
import qualified Data.Aeson                         as Aeson
import qualified Data.ByteString.Internal           as B
import qualified Data.ByteString.Lazy               as BL
import qualified Exchange.Kraken.Contract.Websocket as KW
import qualified System.IO                          as IO
import qualified Utils.WebSocket                    as Socket

import           Control.Concurrent
import           Exchange.Network.Utils
import           Exchange.Types
import           Finance.Types
import           Network.WebSockets

parseKrakenMessage :: (BL.ByteString -> Either String KW.KrakenMessage)
parseKrakenMessage msg = Aeson.eitherDecode msg :: Either String KW.KrakenMessage

websocketHost :: String
websocketHost = "ws.kraken.com"

{- | Websocket worker which receives the order-book updates-}
subscribeToDepthBook :: (BL.ByteString -> IO ()) -> IO ()
subscribeToDepthBook partialHandler = Socket.runSecureClient websocketHost "/" 443 partialHandler subscribe

subscribe :: Connection -> IO ()
subscribe connection = sendTextData connection msg
  where
    msg =
      B.packChars
        "{\"event\": \"subscribe\",\"pair\": [\"XRP/USD\", \"ETH/USD\", \"LTC/USD\", \"BCH/USD\"], \"subscription\": {\"name\": \"book\"}}"
