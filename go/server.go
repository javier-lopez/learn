///bin/true; TMPDIR="$(cd "$(dirname "${0}")" && pwd)" exec /usr/bin/go run "$0" "$@"
package main

import "net/http"
import "fmt"

type mytype struct{}

func (t *mytype) ServeHTTP(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello there from net/http server!")
}


func Custom404Handler(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "text/html; charset=utf-8")
        w.WriteHeader(404)
        template := `
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>ALM Pandora Not Found: 404</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://fonts.googleapis.com/css?family=Inconsolata" rel="stylesheet">
    <style>

      /****************************************************************/
      /***************************** logo *****************************/
      /****************************************************************/

      body {
        -webkit-font-smoothing: antialiased;
        background: #394152;
      }

      * {
        -webkit-box-sizing: border-box;
                box-sizing: border-box;
      }

      @-webkit-keyframes flipY {
        0% {
          -webkit-transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(0deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(0deg) rotatez(0deg);
        }
        20.25% {
          -webkit-transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(90deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(90deg) rotatez(0deg);
        }
        100% {
          -webkit-transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(90deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(90deg) rotatez(0deg);
        }
      }

      @keyframes flipY {
        0% {
          -webkit-transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(0deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(0deg) rotatez(0deg);
        }
        20.25% {
          -webkit-transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(90deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(90deg) rotatez(0deg);
        }
        100% {
          -webkit-transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(90deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(1, 1, 1) rotatex(0deg) rotatey(90deg) rotatez(0deg);
        }
      }

      @-webkit-keyframes flipY-innerCube {
        0% {
          -webkit-transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(0deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(0deg) rotatez(0deg);
        }
        20.25% {
          -webkit-transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(-90deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(-90deg) rotatez(0deg);
        }
        100% {
          -webkit-transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(-90deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(-90deg) rotatez(0deg);
        }
      }

      @keyframes flipY-innerCube {
        0% {
          -webkit-transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(0deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(0deg) rotatez(0deg);
        }
        20.25% {
          -webkit-transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(-90deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(-90deg) rotatez(0deg);
        }
        100% {
          -webkit-transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(-90deg) rotatez(0deg);
                  transform: translateX(-50%) scale3d(0.5, 0.5, 0.5) rotatex(0deg) rotatey(-90deg) rotatez(0deg);
        }
      }

      @-webkit-keyframes flipY-innerShadow {
        0% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(0deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(0deg);
        }
        20.25% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(-90deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(-90deg);
        }
        100% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(-90deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(-90deg);
        }
      }

      @keyframes flipY-innerShadow {
        0% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(0deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(0deg);
        }
        20.25% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(-90deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(-90deg);
        }
        100% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(-90deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(-20px) rotatez(-90deg);
        }
      }

      @-webkit-keyframes flipY-outterShadow {
        0% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(0deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(0deg);
        }
        20.25% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(90deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(90deg);
        }
        100% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(90deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(90deg);
        }
      }

      @keyframes flipY-outterShadow {
        0% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(0deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(0deg);
        }
        20.25% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(90deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(90deg);
        }
        100% {
          -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(90deg);
                  transform: translatex(-50%) rotatex(-90deg) translatez(105px) rotatez(90deg);
        }
      }

      @-webkit-keyframes border-front {
        0% {
          border-width: 1px 6px 6px 1px;
        }
        2.25% {
          border-width: 1px 6px 6px 1px;
        }
        5.75% {
          border-width: 1px 1px 1px 1px;
        }
        100% {
          border-width: 1px 1px 1px 1px;
        }
      }

      @keyframes border-front {
        0% {
          border-width: 1px 6px 6px 1px;
        }
        2.25% {
          border-width: 1px 6px 6px 1px;
        }
        5.75% {
          border-width: 1px 1px 1px 1px;
        }
        100% {
          border-width: 1px 1px 1px 1px;
        }
      }

      @-webkit-keyframes border-back {
        0% {
          border-width: 1px 1px 1px 1px;
        }
        2.25% {
          border-width: 1px 1px 1px 1px;
        }
        5.75% {
          border-width: 1px 1px 6px 6px;
        }
        100% {
          border-width: 1px 1px 6px 6px;
        }
      }

      @keyframes border-back {
        0% {
          border-width: 1px 1px 1px 1px;
        }
        2.25% {
          border-width: 1px 1px 1px 1px;
        }
        5.75% {
          border-width: 1px 1px 6px 6px;
        }
        100% {
          border-width: 1px 1px 6px 6px;
        }
      }

      @-webkit-keyframes border-top {
        0% {
          border-width: 6px 6px 1px 1px;
        }
        2.25% {
          border-width: 6px 6px 1px 1px;
        }
        5.75% {
          border-width: 1px 6px 6px 1px;
        }
        100% {
          border-width: 1px 6px 6px 1px;
        }
      }

      @keyframes border-top {
        0% {
          border-width: 6px 6px 1px 1px;
        }
        2.25% {
          border-width: 6px 6px 1px 1px;
        }
        5.75% {
          border-width: 1px 6px 6px 1px;
        }
        100% {
          border-width: 1px 6px 6px 1px;
        }
      }

      @-webkit-keyframes border-left {
        0% {
          border-width: 1px 1px 6px 6px;
        }
        2.25% {
          border-width: 1px 1px 6px 6px;
        }
        5.75% {
          border-width: 1px 6px 6px 1px;
        }
        100% {
          border-width: 1px 6px 6px 1px;
        }
      }

      @keyframes border-left {
        0% {
          border-width: 1px 1px 6px 6px;
        }
        2.25% {
          border-width: 1px 1px 6px 6px;
        }
        5.75% {
          border-width: 1px 6px 6px 1px;
        }
        100% {
          border-width: 1px 6px 6px 1px;
        }
      }

      @-webkit-keyframes hoverY {
        0% {
          -webkit-transform: translatey(0px);
                  transform: translatey(0px);
        }
        100% {
          -webkit-transform: translatey(-30px);
                  transform: translatey(-30px);
        }
      }

      @keyframes hoverY {
        0% {
          -webkit-transform: translatey(0px);
                  transform: translatey(0px);
        }
        100% {
          -webkit-transform: translatey(-30px);
                  transform: translatey(-30px);
        }
      }

      @-webkit-keyframes scaleBigShadow {
        0% {
          -webkit-transform: scale3d(0.65, 0.65, 0.65);
                  transform: scale3d(0.65, 0.65, 0.65);
        }
        100% {
          -webkit-transform: scale3d(0.6, 0.6, 0.6);
                  transform: scale3d(0.6, 0.6, 0.6);
        }
      }

      @keyframes scaleBigShadow {
        0% {
          -webkit-transform: scale3d(0.65, 0.65, 0.65);
                  transform: scale3d(0.65, 0.65, 0.65);
        }
        100% {
          -webkit-transform: scale3d(0.6, 0.6, 0.6);
                  transform: scale3d(0.6, 0.6, 0.6);
        }
      }

      @-webkit-keyframes scaleSmallShadow {
        0% {
          -webkit-transform: scale3d(0.45, 0.45, 0.45);
                  transform: scale3d(0.45, 0.45, 0.45);
        }
        100% {
          -webkit-transform: scale3d(0.37, 0.37, 0.37);
                  transform: scale3d(0.37, 0.37, 0.37);
        }
      }

      @keyframes scaleSmallShadow {
        0% {
          -webkit-transform: scale3d(0.45, 0.45, 0.45);
                  transform: scale3d(0.45, 0.45, 0.45);
        }
        100% {
          -webkit-transform: scale3d(0.37, 0.37, 0.37);
                  transform: scale3d(0.37, 0.37, 0.37);
        }
      }

      .container {
        display: -webkit-box;
        display: -ms-flexbox;
        display: flex;
        -webkit-box-align: center;
            -ms-flex-align: center;
                align-items: center;
        -webkit-box-pack: center;
            -ms-flex-pack: center;
                justify-content: center;
      }

      .scene {
        position: relative;
        width: 120px;
        height: 120px;
        margin-top: 120px;
        -webkit-transform-style: preserve-3d;
                transform-style: preserve-3d;
        -webkit-transform: translateX(40px) rotatex(-33.5deg) rotatey(45deg);
                transform: translateX(40px) rotatex(-33.5deg) rotatey(45deg);
      }

      .scene .webpack-cube {
        -webkit-transform-style: preserve-3d;
                transform-style: preserve-3d;
        -webkit-animation: hoverY 2s infinite alternate;
                animation: hoverY 2s infinite alternate;
        -webkit-animation-timing-function: ease-in-out;
                animation-timing-function: ease-in-out;
      }

      .scene .outer-cube {
        position: absolute;
        width: 120px;
        height: 120px;
        left: 0;
        top: 0;
        -webkit-transform-style: preserve-3d;
                transform-style: preserve-3d;
        -webkit-animation: flipY 5.2s infinite;
                animation: flipY 5.2s infinite;
        -webkit-backface-visibility: hidden;
                backface-visibility: hidden;
        display: inline-block;
      }

      .scene .outer-cube .face {
        position: absolute;
        width: 100%;
        height: 100%;
        text-align: center;
        background: rgba(255, 255, 255, 0.5);
        line-height: 100px;
        border: 1px solid #394152;
      }

      .scene .outer-cube .face-front {
        -webkit-transform: translatez(60px);
                transform: translatez(60px);
        border-right-width: 6px;
        border-bottom-width: 6px;
        -webkit-animation: border-front 5.2s infinite;
                animation: border-front 5.2s infinite;
        -webkit-animation-fill-mode: forwards;
                animation-fill-mode: forwards;
      }

      .scene .outer-cube .face-back {
        -webkit-transform: rotateY(180deg) translatez(60px);
                transform: rotateY(180deg) translatez(60px);
        -webkit-animation: border-back 5.2s infinite;
                animation: border-back 5.2s infinite;
        -webkit-animation-fill-mode: forwards;
                animation-fill-mode: forwards;
      }

      .scene .outer-cube .face-top {
        -webkit-transform: rotatex(90deg) translatez(60px);
                transform: rotatex(90deg) translatez(60px);
        border-top-width: 6px;
        border-right-width: 6px;
        -webkit-animation: border-top 5.2s infinite;
                animation: border-top 5.2s infinite;
        -webkit-animation-fill-mode: forwards;
                animation-fill-mode: forwards;
      }

      .scene .outer-cube .face-bottom {
        -webkit-transform: rotatex(-90deg) translatez(60px);
                transform: rotatex(-90deg) translatez(60px);
      }

      .scene .outer-cube .face-left {
        -webkit-transform: rotateY(-90deg) translatez(60px);
                transform: rotateY(-90deg) translatez(60px);
        border-left-width: 6px;
        border-bottom-width: 6px;
        -webkit-animation: border-left 5.2s infinite;
                animation: border-left 5.2s infinite;
        -webkit-animation-fill-mode: forwards;
                animation-fill-mode: forwards;
      }

      .scene .outer-cube .face-right {
        -webkit-transform: rotateY(90deg) translatez(60px);
                transform: rotateY(90deg) translatez(60px);
      }

      .scene .inner-cube {
        display: inline-block;
        position: absolute;
        width: 120px;
        height: 120px;
        left: 0;
        top: -2px;
        -webkit-transform-style: preserve-3d;
                transform-style: preserve-3d;
        -webkit-animation: flipY-innerCube 5.2s infinite;
                animation: flipY-innerCube 5.2s infinite;
      }

      .scene .inner-cube .face {
        position: absolute;
        width: 100%;
        height: 100%;
        text-align: center;
        /*background: #000;*/
        background: #fff;
        line-height: 100px;
        border: 2px solid #394152;
      }

      .scene .inner-cube .face-front {
        -webkit-transform: translatez(60px);
                transform: translatez(60px);
      }

      .scene .inner-cube .face-back {
        -webkit-transform: rotateY(180deg) translatez(60px);
                transform: rotateY(180deg) translatez(60px);
      }

      .scene .inner-cube .face-top {
        -webkit-transform: rotatex(90deg) translatez(60px);
                transform: rotatex(90deg) translatez(60px);
      }

      .scene .inner-cube .face-bottom {
        -webkit-transform: rotatex(-90deg) translatez(60px);
                transform: rotatex(-90deg) translatez(60px);
      }

      .scene .inner-cube .face-left {
        -webkit-transform: rotateY(-90deg) translatez(60px);
                transform: rotateY(-90deg) translatez(60px);
      }

      .scene .inner-cube .face-right {
        -webkit-transform: rotateY(90deg) translatez(60px);
                transform: rotateY(90deg) translatez(60px);
      }

      .scene .shadows-outer-container {
        display: inline-block;
        -webkit-transform-style: preserve-3d;
                transform-style: preserve-3d;
        width: 120px;
        height: 120px;
        -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(110px);
                transform: translatex(-50%) rotatex(-90deg) translatez(110px);
        -webkit-animation: flipY-outterShadow 5.2s infinite;
                animation: flipY-outterShadow 5.2s infinite;
      }

      .scene .shadows-outer-container .shadow-outer {
        display: inline-block;
        position: absolute;
        width: 120px;
        height: 120px;
        background-color: rgba(255, 255, 255, 0.5);
        -webkit-animation: scaleBigShadow 2s infinite alternate;
                animation: scaleBigShadow 2s infinite alternate;
        -webkit-animation-timing-function: ease-in-out;
                animation-timing-function: ease-in-out;
        -webkit-box-shadow: 0px 0px 45px 35px rgba(255, 255, 255, 0.5);
                box-shadow: 0px 0px 45px 35px rgba(255, 255, 255, 0.5);
        -webkit-transform-origin: center center;
                transform-origin: center center;
        -webkit-transform: scale3d(0.8, 0.8, 0.8);
                transform: scale3d(0.8, 0.8, 0.8);
      }

      .scene .shadows-inner-container {
        display: inline-block;
        -webkit-transform-style: preserve-3d;
                transform-style: preserve-3d;
        width: 120px;
        height: 120px;
        -webkit-transform: translatex(-50%) rotatex(-90deg) translatez(0px) rotatez(0deg);
                transform: translatex(-50%) rotatex(-90deg) translatez(0px) rotatez(0deg);
        -webkit-animation: flipY-innerShadow 5.2s infinite;
                animation: flipY-innerShadow 5.2s infinite;
      }

      .scene .shadows-inner-container .shadow-inner {
        display: inline-block;
        position: absolute;
        width: 120px;
        height: 120px;
        border-radius: 15px;
        background: -webkit-gradient(linear, left bottom, left top, color-stop(10%, transparent), color-stop(50%, rgba(109, 109, 109, 0.7)), to(transparent)), -webkit-gradient(linear, left top, right top, color-stop(10%, transparent), color-stop(50%, rgba(109, 109, 109, 0.7)), to(transparent)), -webkit-gradient(linear, left top, left bottom, color-stop(10%, transparent), color-stop(50%, rgba(109, 109, 109, 0.7)), to(transparent)), -webkit-gradient(linear, right top, left top, color-stop(10%, transparent), color-stop(50%, rgba(109, 109, 109, 0.7)), to(transparent));
        background: linear-gradient(0deg, transparent 10%, rgba(109, 109, 109, 0.7) 50%, transparent), linear-gradient(90deg, transparent 10%, rgba(109, 109, 109, 0.7) 50%, transparent), linear-gradient(180deg, transparent 10%, rgba(109, 109, 109, 0.7) 50%, transparent), linear-gradient(270deg, transparent 10%, rgba(109, 109, 109, 0.7) 50%, transparent);
        -webkit-animation: scaleSmallShadow 2s infinite alternate;
                animation: scaleSmallShadow 2s infinite alternate;
        -webkit-animation-timing-function: ease-in-out;
                animation-timing-function: ease-in-out;
        -webkit-transform-origin: center center;
                transform-origin: center center;
        -webkit-transform: scale3d(0.4, 0.4, 0.4);
                transform: scale3d(0.4, 0.4, 0.4);
      }

      /****************************************************************/
      /*************************** clit text **************************/
      /****************************************************************/

      .logo-type {
        font-size: 2.5em;
        font-family: 'Inconsolata', menlo, monospace;
        font-weight: 600;
        color: #399;

        width: 100%;
        height: 100%;
        padding-top: 100px;
        padding-bottom: 30px;
        text-align: center;
      }

      .logo-type:before {
        content: '➜ ~';
        color: #93a1a1;
      }

      .logo-type::first-letter {
        color: #596e75;
      }

      .logo-type:after {
        content: '▉';
        color: rgba(255, 255, 255, 0.5);
        animation: blink-animation 1s steps(1, start) infinite;
      }

      @keyframes blink-animation {
        from, to { opacity: 0 }
        50% { opacity: 1 }
      }

      /****************************************************************/
      /************************* content text *************************/
      /****************************************************************/

      .strong {
          font-weight: bold;
      }

      .content {
          color: #fff;
          width: 70%;
          margin: auto;
      }

      .content .subtitle {
          text-align: center;
          font-size: 1.2em;
          padding-bottom: 20px;
      }

      .content a {
          color: #fff;
      }

      .signature {
          color: #fff;
          text-align: center;
      }
    </style>
  </head>

  <body>
    <div class="container">
      <div class="scene">
        <div class="webpack-cube">
          <div class="outer-cube">
            <div class="face face-top"></div>
            <div class="face face-bottom"></div>
            <div class="face face-left"></div>
            <div class="face face-right"></div>
            <div class="face face-front"></div>
            <div class="face face-back"></div>
          </div>
          <div class="inner-cube">
            <div class="face face-top"></div>
            <div class="face face-bottom"></div>
            <div class="face face-left"></div>
            <div class="face face-right"></div>
            <div class="face face-front"></div>
            <div class="face face-back"></div>
          </div>
        </div>

        <div class="shadows-inner-container">
          <div class="shadow-inner"></div>
        </div>
      </div>
    </div>

    <div class="content">
      <div class="logo-type">
          404
      </div>

      <div class="subtitle">We are sorry but the required ALM Pandora Service <span class="strong">doesn't exists</strong>.</div>
      <div class="subtitle">Please try with another URL.</div>
    </div>

  </body>
</html>
        `
        fmt.Fprint(w, template)
}

func Default404Handler(w http.ResponseWriter, r *http.Request) {
    http.NotFound(w, r)
}

func main() {
        t := new(mytype)
        http.Handle("/", t)

        http.HandleFunc("/custom404/", Custom404Handler)
        http.HandleFunc("/404/", Default404Handler)

        http.ListenAndServe(":8080", nil)
}
