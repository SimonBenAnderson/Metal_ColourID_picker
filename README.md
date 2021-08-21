#  Swift - Pick Selection

## Overview
Setting up Color pick id

- Creating a second render pass
- Using Blitt command to copy data

## TODO
- [ ] Create a button to alternate between passes, so the viewer can see the id pass 

## Process
- To setup the ColourID we first need to encode the id of the object into a unique colour
- Then we need to store the colourID and object in a look up table
- Pass the colour id into the shader, so that it can be computed, and pass it to the fragment shader
- We then need to get the computed id pass back from the gpu
- Query the idPass at the point where one clicks on the screen

## Resource References
- https://moddb.fandom.com/wiki/OpenGL_Selection_Using_Unique_Color_IDs
- http://www.opengl-tutorial.org/miscellaneous/clicking-on-objects/picking-with-an-opengl-hack/
- https://www.youtube.com/watch?v=OSrA1kTfwVY&t=392s
