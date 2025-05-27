<!-- Copyright (C) 2012 Bubbus -->
# Holopad - A Hologram modelling GUI/exporter

### A Hologram modelling GUI/exporter made by [Bubbus](https://github.com/bubbus) (splambob) and released on 24/08/2012 08:16 AM

(I'm pretty sure this counts as a Wiremod Addon )

One day last year I got annoyed because I was trying to make a detailed holo model and twiddling numbers in E2 isn't fun.
Instead of doing the logical thing - flip the computer through the window and go outside - I decided to spend more time creating Holopad than finishing that model would ever have taken

What this thing does is allows you to create a hologram model with a modelling program (like 3DSMAX or Blender) and then export the model into an E2 chip - without ever touching a line of E2 code. I tried making the layout of the editor as intuitive as possible, and so far I haven't heard (many) complaints. We've used it so far to create vehicle parts, hats, characters and weapons, and I can't wait to see what you'll do with it!

I think that Holopad is complete enough to release it to a wider audience, but be aware that it's still in development.
I've been testing it with friends for a while now and we haven't discovered any huge bugs for a while, so today I'm setting it loose.

### Pix for clix;

UFO to E2 in 10 seconds;

![Image1]
![Image2]
![Image3]
Now with holoModelAny support!
![Image4]
([Screenshots][hidden_screenshots] [of the][hidden_of_the] [development][hidden_development] [process][hidden_process])

### Super Classy Art Gallery

[Programmer art by me][art_by_me]

[Superior art by The Emperor of Justice!!!][the_emperor_of_justice]

More art incoming!


### Usage
In order to use Holopad, download it from a link above, put it in your addons folder, open your console and type Holopad. Bind it to a key if you like 
The buttons on the top strip are basic commands: save/load from project file, export to E2, spawn/delete holos, and the various tool-modes you'll be using to make your model. When you select a tool-mode, relevant operations will appear in the panel on the right. You can spawn holos by clicking on the "Spawn Holos" button and then selecting a holo from the spawn menu on the left. Make sure to save your progress regularly in Project files by using the "Save to PRJ" button. EXPORTING TO E2 IS NOT THE SAME AS SAVING YOUR WORK
If they're needed, I'll create a series of video tutorials on how to use the editor. I can't start on these right now but I'll definitely do so when GM13 comes out.



### Bug reports and suggestions!
I'm damn sure that I'm not the perfect programmer, so there will be times that you'll come across a bug or two. If you find a bug, please report it in here, PM it to me or send me an email. I'll love you forever (0.1% homo).
If you have an idea for a feature or an improvement, please contact me in the same way as if you had a bug (easier for me to find!) Half of the features in Holopad were requested by my beta team, so I'm more than likely to add your suggestion too if it's sensible!

### Planned features

Code:
```
[ ] = TODO, [/] = Partially done, [-] = Cancelled, [X] = Completed!

BETA 7:
[X] Parent-local orientation (exporter)
[X] Copy/paste buttons for orientation
[X] Camera option; hammer-style with wasd (ty kai)
[X] Editable dongle orientation (angle or holo-based) (ty lubstar)
[X] Material selection list [i]maybe[/i] (ty emperor)
[ ] Persist window positions and sizes (ty cre)
[ ] Selection box tool (ty Vicious713)
[ ] Enable multiple selection on selection list (ty Vicious713)
BETA 8:
[ ] Group transformations
[ ] Video tutorials (I need a good mic and silence, I'll definitely start on these when GM13 comes out)
[ ] Model selection list on model re-selection button
[ ] Adaptive grid size
[ ] Important things that I forgot about but people will tell me to do (maybe you?!)
ONGOING:
[/] Expand on keyboard binds (suggest some! you!!)
[/] Persistence
??????:
[X] [addons\holopad\lua\holopad\serialize\lib_common.lua:155] attempt to concatenate local 'v' (a table value) (ty Zoombahh)
[ ] [@addons\holopad\lua\holopad\mouse\obj_movemode.lua:152] Tried to move an Entity but Entity's screen position was undefined!
[X] [addons\holopad\lua\holopad\gui\dholopad.lua:114] attempt to call method 'Close' (a nil value)
[X] Editable background colour
[X] White Lights 2
[ ] Decouple entity properties from Select tool-menu (ty Zoombahh)
[ ] What is wrong with the colour picker?!?!
[ ] Make a list of hotkeys! (ty Zoombahh)
[ ] Make grid movement easier (ty Zoombahh)
[ ] Workaround for bad GM13 model scale function (ty Zoombahh)
[ ] nil-proofing to all file i/o (ty Zoombahh)
```

### Credits

I did most of the work (code, textures etc), but I'd be far behind if not for these people;\
**Cre8or, Lubstar, PcmciaKai, The Emperor of Justice!!!** (sorry if i forgot anyone) : The contributing beta team\
**The Emperor of Justice!!!** created the default "Holopad" Project file\
**The Gluttony community** for putting up with my development thread :v:\
**Vercas**; contributing a holo creation template and creating the vON de/serializer (tyvm, it rocks!)\
**The FP build community** for helping me test the earlier versions of Holopad.\
**The FP lua community** for answering questions and being awesome.\
**Divran** for fixing the scaling problems with tiny holos.

Have fun!

<!-- REFERENCES / SOURCES -->
[art_by_me]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/lol2.png
[the_emperor_of_justice]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/emperor.jpg
[hidden_screenshots]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/gm_desertdriving0006.jpg
[hidden_of_the]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/gm_desertdriving0007.jpg
[hidden_development]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/gm_desertdriving0010.jpg
[hidden_process]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/freespace06_v2-10054.jpg

<!-- IMAGE REFERENCES -->
[Image1]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/lol1.png
[Image2]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/lol4.png
[Image3]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/gm_construct0004.jpg
[Image4]: https://github.com/GMod-Creativity/Holopad2/blob/main/assets/images/lol3.png
