module Main where

import Prelude

import Data.Int (toNumber)
import Data.Maybe (fromJust)
import Effect (Effect)
import Effect.Console (log)
import Graphics.Canvas (Context2D, beginPath, clearRect, getCanvasElementById, getContext2D, lineTo, moveTo, restore, rotate, save, stroke, translate)
import Partial.Unsafe (unsafePartial)
import Web.Event.Event (Event, EventType(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.Window (toEventTarget)
import Web.UIEvent.MouseEvent (fromEvent, clientX, clientY)

type Depth = Int
type LineLength = Number
type Scale = Number
type Angle = Number

drawTree :: Context2D -> Depth -> LineLength -> Scale -> Angle -> Effect Unit
drawTree ctx 0 lineLength scale _ = do
  log "Draw tree"
  save ctx
  beginPath ctx
  moveTo ctx 0.0 0.0
  lineTo ctx 0.0 (-lineLength)
  stroke ctx
  restore ctx
drawTree ctx depth lineLength scale angle = do
  log "Draw tree"
  save ctx
  beginPath ctx
  moveTo ctx 0.0 0.0
  lineTo ctx 0.0 (-lineLength)
  stroke ctx
  restore ctx
  save ctx
  translate ctx { translateX: 0.0, translateY: (-lineLength) }
  save ctx
  rotate ctx angle
  drawTree ctx (depth - 1) (lineLength * scale) scale (angle * scale)
  restore ctx
  save ctx
  rotate ctx (-angle)
  drawTree ctx (depth - 1) (lineLength * scale) scale (angle * scale)
  restore ctx
  restore ctx

draw :: Context2D -> Int -> Number -> Number -> Number -> Effect Unit
draw ctx d l s a = do
  log "Draw"
  clearRect ctx { x: 0.0, y: 0.0, height: 400.0, width: 400.0 }
  save ctx
  translate ctx { translateX: 200.0, translateY: 300.0 }
  drawTree ctx d l s a
  restore ctx

listener :: Context2D -> Event -> Effect Unit
listener ctx e = do
  let me = unsafePartial $ fromJust (fromEvent e)
  let x = clientX me
  let y = clientY me
  log "listener callback"
  draw ctx (y / 60) 30.0 0.9 ((toNumber x) / 1000.0)

main :: Effect Unit
main = do
  log "Main"
  canvas <- unsafePartial $ fromJust <$> getCanvasElementById "cnvs"
  ctx <- getContext2D canvas
  lstnr <- eventListener $ listener ctx
  wnd <- window
  addEventListener (EventType "mousemove") lstnr false (toEventTarget wnd)
