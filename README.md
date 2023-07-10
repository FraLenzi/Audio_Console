# Audio_Console

Laboratory project done during the “Digital Electronics Systems Design” master’s degree course. 
The aim of this project was to program the Artix 7 FPGA on the Digilent Basys 3 board to use the I2S2 sound Pmod and the JSTK2 Pmod from Digilent in order to acquire a signal from an audio source, process it, and deliver it to a loudspeaker through a 3.5mm jack cable. 
Particular attention was posed in the optimization of timing, resource usage and correctness of protocols, through the hardware debugger. 
The design we made featured mute control, volume control, controllable audio mobile mean filter and stereo control, along with a RGB led notification of the current console status. 
All those features were implemented through VHDL and Block Design using Vivado.
