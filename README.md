#  Swift - Pick Selection

## Overview
Setting up Color pick id

- Creating a second render pass
- Using Blitt command to copy data


## Notes:

After implementing the two texture outputs and the blit encoder, I seem to be getting a **GPU Soft Fault**, which is causing random frames to output garbage. It usualy is every second frame.
Looking at implementing frame buffers to see if it might be a frame draw issue


### 2nd Draw error

There is a drawing issue when every second frame sometimes seems to be  drawn as garbage. As the project does not currently use **Semaphore**, I think it may be a read write issue.

Reference:
https://developer.apple.com/documentation/metal/synchronization/synchronizing_cpu_and_gpu_work


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
