#Away3D for OpenFL

##Introduction
Away3D for OpenFl is a port of the Flash Away3D engine, enabling targetting Flash, Neko, HTML5 and native CPP builds for OSX, Windows, iOS, Android, etc. 

##Features
- AGLSL conversion of AGAL code to support OpenGLES.
- Targets cross platform - web, mobile, desktop
- Texture mapping with mipmapping
- Lighting
- Shadow mapping (in most cases)
- Model loading: 3DS, AWD, MD5, MD2, DAE
- Skeleton animation
- Skinned animation
- 3D particle system
- Line drawing (Segments & SegmentSets)

##Installation

    haxelib install away3d
    
##Getting Started

    lime create away3d      // To list all of the available examples
    lime create away3d:Basic_View      // To install the Basic_View example
    lime create away3d:Basic_View /destinationFolder  // To install the example to a specific location
    
A typical project.xml file would look as follows. Each example in the away3d-examples repository has it's own project.xml.

    <?xml version="1.0" encoding="utf-8"?>
    <project>
        
        <meta title="Basic View Away3D OpenFL" package="away3d.examples.BasicView" version="1.0.0" />
        <app main="Basic_View" file="Basic_View" path="Export" />
        
        <window width="1024" height="700" if="desktop"/>
        <window width="0" height="0" if="html5" />
        <window orientation="landscape" vsync="true" if="cpp"/>
        <window fps="60" hardware="true" allow-shaders="true" require-shaders="true" depth-buffer="true" stencil-buffer="true"  background="#000000"  />
            
        <source path="src" />
        
        <haxelib name="format" if="html5" />
        <haxelib name="away3d" />
        <haxelib name="openfl" />
        
        <assets path="embeds" exclude="away3d.svg" />

        <icon path="embeds/away3d.svg" />
        
        <haxedef name="source-map-content" if="html5" />
        <haxedef name="dom" if="html5" />

        <android minimum-sdk-version="10" />

    </project>

##Building Examples
To build an example, 'cd' to the example's folder e.g. Basic_View and use the following.

	openfl test <target>     - where target is html5, windows, mac, neko, ios, android, etc
	
NOTE: When using OpenFL 3.x and the non-html5 targets, please add the -Dlegacy option as Away3D doesn't fully support OpenFL-next for CPP targets as yet.

	openfl test mac -Dlegacy
	
##Dependencies

Away3D currently requires OpenFL 2.2.4, and Lime 2.1.0. You can install these older versions with haxelib like this:

	haxelib install openfl 2.2.4
	haxelib install lime 2.1.0
	
You can then set your active libary versions like so:
	
	haxelib set openfl 2.2.4
	haxelib set lime 2.1.0

##License

Copyright 2014 The Away3D Team

The Away3D OpenFL port is free, open-source software under the MIT license.
