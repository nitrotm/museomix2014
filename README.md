# Museomix 2014 @ MAH GENEVA

## Overview

Prototype of the 'MAH Machine: Mixing Art & History'. The project is about two user interfaces.

First a 'slot machine' is selecting some art pieces out of the museum collection. Designed with a hardware lever like in a real machine. This machine is also printing a ticket containing the 3 selected pieces for the visitor.

Then - if the visitor wish it - a second machine (table screen) can be used to write a short story about how s/he perceives the 3 art pieces. Many type of inputs are possible in theory (text, drawing, audio, video, ...) but only a simple text input is implemented (could be in the form of keywords, questions, poems, haikus, jokes...). The machine also displays previous entered stories to passing visitors.

http://www.museomix.org/prototypes/mah-machine/

## Technology

- Node.js
- HTML5/Bootstrap/Angular.js
- WebGL
- TexLive (LaTeX)

## Setup

The 'slot machine' and table screen need node.js to run a small local web server. As we were fortunate to have access to a non-choice of 2 Windows machines and 1 screen, everything was installed in a breeze.

That explains why the code refer gladly to strange paths within the system drive to run several tools, including TexLive (Windows x64 edition) and SumatraPDF.

To install the server app (same on both machines):

  git clone https://github.com/repo

And then:

  npm install
  bower install
  node run.js

Assuming that the computers are properly setup and arduino is plugged in, the generator ('slot machine') can be opened with:

  chrome --kiosk "http://localhost:8080/generator.html"

And the designer ('table screen') with following url:

  chrome --kiosk "http://localhost:8080/designer.html"

## Technical authors:

Quentin Berthet: arduino and cool hardware hacking.
Antony Ducommun: anti-tecture and 'slot machine' app.
Geoffroy Perriard: 'table screen' app.

## License

CC-BY-SA
