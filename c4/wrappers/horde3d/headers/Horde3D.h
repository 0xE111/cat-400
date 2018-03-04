#ifdef C2NIM
#  skipcomments
#  dynlib lib
#  cdecl
#  if defined(windows)
#    define lib "Horde3D.dll"
#  elif defined(macosx)
#    define lib "libHorde3D.dylib"
#  else
#    define lib "libHorde3D.so"
#  endif
#endif

// *************************************************************************************************
//
// Horde3D
//   Next-Generation Graphics Engine
// --------------------------------------
// Copyright (C) 2006-2016 Nicolas Schulz and Horde3D team
//
// This software is distributed under the terms of the Eclipse Public License v1.0.
// A copy of the license may be obtained at: http://www.eclipse.org/legal/epl-v10.html
//
// *************************************************************************************************

/*	Title: Horde3D API */

/*	Topic: Conventions
		Some conventions for the API.
	
	Horde3D uses a right-handed coordinate system, where y is the up-axis and the positive z-axis is
	pointing out of the screen. The rotations are specified in degrees and rotation direction is
	counter-clockwise when looking down the axis from the the positive end towards the origin. View
	vectors like the camera or light direction are always pointing along the negative z-axis when no
	transformation is applied. Matrices in Horde are stored in a column-major memory layout. When
	Euler angles are used, the rotation order is YXZ [*vec], so the z-rotation is applied first.
*/


// *************************************************************************************************
// Core Library
// *************************************************************************************************

/* Group: Typedefs and constants */

/*	Constants: Typedefs
	Res   - handle to resource (type: int32)
	Node  - handle to scene node (type: int32)
*/
typedef int Res;
typedef int Node;


/*	Constants: Predefined constants
	RootNode  - Scene root node handle
*/
const Node RootNode = 1;

/* Group: Enumerations */
enum RenderDevice
{
	/* Enum: RenderDevice
	The available engine Renderer backends.

	OpenGL2				- use OpenGL 2 as renderer backend (can be used to force OpenGL 2 when higher version is undesirable)
	OpenGL4				- use OpenGL 4 as renderer backend (falls back to OpenGL 2 in case of error)
	*/
		OpenGL2 = 2,
		OpenGL4 = 4
};


enum Options
{
	/* Enum: Options
			The available engine option parameters.
		
		MaxLogLevel         - Defines the maximum log level; only messages which are smaller or equal to this value
		                      (hence more important) are published in the message queue. (Default: 4)
		MaxNumMessages      - Defines the maximum number of messages that can be stored in the message queue (Default: 512)
		TrilinearFiltering  - Enables or disables trilinear filtering for textures. (Values: 0, 1; Default: 1)
		MaxAnisotropy       - Sets the maximum quality for anisotropic filtering. (Values: 1, 2, 4, 8, 16; Default: 1)
		TexCompression      - Enables or disables texture compression; only affects textures that are
		                      loaded after setting the option. (Values: 0, 1; Default: 0)
		SRGBLinearization   - Eanbles or disables gamma-to-linear-space conversion of input textures that are tagged as sRGB (Values: 0, 1; Default: 0)
		LoadTextures        - Enables or disables loading of textures referenced by materials; this can be useful to reduce
		                      loading times for testing. (Values: 0, 1; Default: 1)
		FastAnimation       - Disables or enables inter-frame interpolation for animations. (Values: 0, 1; Default: 1)
		ShadowMapSize       - Sets the size of the shadow map buffer (Values: 128, 256, 512, 1024, 2048; Default: 1024)
		SampleCount         - Maximum number of samples used for multisampled render targets; only affects pipelines
		                      that are loaded after setting the option. (Values: 0, 2, 4, 8, 16; Default: 0)
		WireframeMode       - Enables or disables wireframe rendering
		DebugViewMode       - Enables or disables debug view where geometry is rendered in wireframe without shaders and
		                      lights are visualized using their screen space bounding box. (Values: 0, 1; Default: 0)
		DumpFailedShaders   - Enables or disables storing of shader code that failed to compile in a text file; this can be
		                      useful in combination with the line numbers given back by the shader compiler. (Values: 0, 1; Default: 0)
		GatherTimeStats     - Enables or disables gathering of time stats that are useful for profiling (Values: 0, 1; Default: 1)
	*/
		MaxLogLevel = 1,
		MaxNumMessages,
		TrilinearFiltering,
		MaxAnisotropy,
		TexCompression,
		SRGBLinearization,
		LoadTextures,
		FastAnimation,
		ShadowMapSize,
		SampleCount,
		WireframeMode,
		DebugViewMode,
		DumpFailedShaders,
		GatherTimeStats
};

enum Stats
{
	/* Enum: Stats
			The available engine statistic parameters.
		
		TriCount          - Number of triangles that were pushed to the renderer
		BatchCount        - Number of batches (draw calls)
		LightPassCount    - Number of lighting passes
		FrameTime         - Time in ms between two FinalizeFrame calls
		AnimationTime     - CPU time in ms spent for animation
		GeoUpdateTime     - CPU time in ms spent for software skinning and morphing
		ParticleSimTime   - CPU time in ms spent for particle simulation and updates
		FwdLightsGPUTime  - GPU time in ms spent for forward lighting passes
		DefLightsGPUTime  - GPU time in ms spent for drawing deferred light volumes
		ShadowsGPUTime    - GPU time in ms spent for generating shadow maps
		ParticleGPUTime   - GPU time in ms spent for drawing particles
		TextureVMem       - Estimated amount of video memory used by textures (in Mb)
		GeometryVMem      - Estimated amount of video memory used by geometry (in Mb),
		ComputeGPUTime	  - GPU time in ms spent for processing compute shaders
	*/
		TriCount = 100,
		BatchCount,
		LightPassCount,
		FrameTime,
		AnimationTime,
		GeoUpdateTime,
		ParticleSimTime,
		FwdLightsGPUTime,
		DefLightsGPUTime,
		ShadowsGPUTime,
		ParticleGPUTime,
		TextureVMem,
		GeometryVMem,
		ComputeGPUTime
};

enum DeviceCapabilities
{
	/* Enum: DeviceCapabilities
	The available GPU capabilities.

	GeometryShaders			- GPU supports runtime geometry generation via geometry shaders
	TessellationShaders     - GPU supports tessellation
	ComputeShaders		    - GPU supports general-purpose computing via compute shaders
	*/
		GeometryShaders = 200,
		TessellationShaders,
		ComputeShaders
};

enum ResTypes
{
	/* Enum: ResTypes
			The available resource types.
		
		Undefined       - An undefined resource, returned by getResourceType in case of error
		SceneGraph      - Scene graph subtree stored in XML format
		Geometry        - Geometrical data containing bones, vertices and triangles
		Animation       - Animation data
		Material        - Material script
		Code            - Text block containing shader source code
		Shader          - Shader program
		Texture         - Texture map
		ParticleEffect  - Particle configuration
		Pipeline        - Rendering pipeline
		ComputeBuffer   - Buffer with arbitrary data that can be accessed and modified by compute shaders
	*/
		Undefined = 0,
		SceneGraph,
		Geometry,
		Animation,
		Material,
		Code,
		Shader,
		Texture,
		ParticleEffect,
		Pipeline,
		ComputeBuffer
};

enum ResFlags
{
	/* Enum: ResFlags
			The available flags used when adding a resource.
			
		NoQuery           - Excludes resource from being listed by queryUnloadedResource function.
		NoTexCompression  - Disables texture compression for Texture resource.
		NoTexMipmaps      - Disables generation of mipmaps for Texture resource.
		TexCubemap        - Sets Texture resource to be a cubemap.
		TexDynamic        - Enables more efficient updates of Texture resource streams.
		TexRenderable     - Makes Texture resource usable as render target.
		TexSRGB           - Indicates that Texture resource is in sRGB color space and should be converted
		                    to linear space when being sampled.
	*/
		NoQuery = 1,
		NoTexCompression = 2,
		NoTexMipmaps = 4,
		TexCubemap = 8,
		TexDynamic = 16,
		TexRenderable = 32,
		TexSRGB = 64
};


enum Formats
{
	/* Enum: Formats
			The available resource stream formats.
			
		Unknown      - Unknown format
		TEX_BGRA8    - 8-bit BGRA texture
		TEX_DXT1     - DXT1 compressed texture
		TEX_DXT3     - DXT3 compressed texture
		TEX_DXT5     - DXT5 compressed texture
		TEX_RGBA16F  - Half float RGBA texture
		TEX_RGBA32F  - Float RGBA texture
	*/
		Unknown = 0,
		TEX_BGRA8,
		TEX_DXT1,
		TEX_DXT3,
		TEX_DXT5,
		TEX_RGBA16F,
		TEX_RGBA32F
};


enum GeoRes
{
	/* Enum: GeoRes
			The available Geometry resource accessors.
		
		GeometryElem         - Base element
		GeoIndexCountI       - Number of indices [read-only]
		GeoVertexCountI      - Number of vertices [read-only]
		GeoIndices16I        - Flag indicating whether index data is 16 or 32 bit [read-only]
		GeoIndexStream       - Triangle index data (uint16 or uint32, depending on flag)
		GeoVertPosStream     - Vertex position data (float x, y, z)
		GeoVertTanStream     - Vertex tangent frame data (float nx, ny, nz, tx, ty, tz, tw)
		GeoVertStaticStream  - Vertex static attribute data (float u0, v0,
		                         float4 jointIndices, float4 jointWeights, float u1, v1)
	*/
		GeometryElem = 200,
		GeoIndexCountI,
		GeoVertexCountI,
		GeoIndices16I,
		GeoIndexStream,
		GeoVertPosStream,
		GeoVertTanStream,
		GeoVertStaticStream
};

enum AnimRes
{
	/* Enum: AnimRes
			The available Animation resource accessors.	  
		
		EntityElem      - Stored animation entities (joints and meshes)
		EntFrameCountI  - Number of frames stored for a specific entity [read-only]
	*/
		EntityElem = 300,
		EntFrameCountI
};

enum MatRes
{
	/* Enum: MatRes
			The available Material resource accessors.

		MaterialElem  - Base element
		SamplerElem   - Sampler element
		UniformElem   - Uniform element
		MatClassStr   - Material class
		MatLinkI      - Material resource that is linked to this material
		MatShaderI    - Shader resource
		SampNameStr   - Name of sampler [read-only]
		SampTexResI   - Texture resource bound to sampler
		UnifNameStr   - Name of uniform [read-only]
		UnifValueF4   - Value of uniform (a, b, c, d)
	*/
		MaterialElem = 400,
		SamplerElem,
		UniformElem,
		MatClassStr,
		MatLinkI,
		MatShaderI,
		SampNameStr,
		SampTexResI,
		UnifNameStr,
		UnifValueF4
};

enum ShaderRes
{
	/* Enum: ShaderRes
			The available Shader resource accessors.

		ContextElem     - Context element 
		SamplerElem     - Sampler element
		UniformElem     - Uniform element
		ContNameStr     - Name of context [read-only]
		SampNameStr     - Name of sampler [read-only]
		SampDefTexResI  - Default texture resouce of sampler [read-only]
		UnifNameStr     - Name of uniform [read-only]
		UnifSizeI       - Size (number of components) of uniform [read-only]
		UnifDefValueF4  - Default value of uniform (a, b, c, d)
	*/
		ContextElem = 600,
		SamplerElem,
		UniformElem,
		ContNameStr,
		SampNameStr,
		SampDefTexResI,
		UnifNameStr,
		UnifSizeI,
		UnifDefValueF4
};

enum TexRes
{
	/* Enum: TexRes
			The available Texture resource accessors.

		TextureElem     - Base element
		ImageElem       - Subresources of the texture. A texture consists, depending on the type,
		                  of a number of equally sized slices which again can have a fixed number
		                  of mipmaps. Each image element represents the base image of a slice or
		                  a single mipmap level of the corresponding slice.
		TexFormatI      - Texture format [read-only]
		TexSliceCountI  - Number of slices (1 for 2D texture and 6 for cubemap) [read-only]
		ImgWidthI       - Image width [read-only]
		ImgHeightI      - Image height [read-only]
		ImgPixelStream  - Pixel data of an image. The data layout matches the layout specified
		                  by the texture format with the exception that half-float is converted
		                  to float. The first element in the data array corresponds to the lower
		                  left corner.
	*/
		TextureElem = 700,
		ImageElem,
		TexFormatI,
		TexSliceCountI,
		ImgWidthI,
		ImgHeightI,
		ImgPixelStream
};

enum PartEffRes
{
	/* Enum: PartEffRes
			The available ParticleEffect resource accessors.

		ParticleElem     - General particle configuration
		ChanMoveVelElem  - Velocity channel
		ChanRotVelElem   - Angular velocity channel
		ChanSizeElem     - Size channel
		ChanColRElem     - Red color component channel
		ChanColGElem     - Green color component channel
		ChanColBElem     - Blue color component channel
		ChanColAElem     - Alpha channel
		PartLifeMinF     - Minimum value of random life time (in seconds)
		PartLifeMaxF     - Maximum value of random life time (in seconds)
		ChanStartMinF    - Minimum for selecting initial random value of channel
		ChanStartMaxF    - Maximum for selecting initial random value of channel
		ChanEndRateF     - Remaining percentage of initial value when particle is dying
	*/
		ParticleElem = 800,
		ChanMoveVelElem,
		ChanRotVelElem,
		ChanSizeElem,
		ChanColRElem,
		ChanColGElem,
		ChanColBElem,
		ChanColAElem,
		PartLifeMinF,
		PartLifeMaxF,
		ChanStartMinF,
		ChanStartMaxF,
		ChanEndRateF,
		ChanDragElem
};

enum PipeRes
{
	/* Enum: PipeRes
			The available Pipeline resource accessors.

		StageElem         - Pipeline stage
		StageNameStr      - Name of stage [read-only]
		StageActivationI  - Flag indicating whether stage is active
	*/
		StageElem = 900,
		StageNameStr,
		StageActivationI
};

enum ComputeBufRes
{
	/* Enum: ComputeBufRes
	The available ComputeBuffer resource accessors.

	ComputeBufElem				- General compute buffer configuration
	DrawParamsElem				- Specifies parameters for shader bindings
	CompBufDataSizeI			- Size of the buffer
	CompBufDrawableI			- Use this compute buffer as a source of vertices for drawing [0, 1]. Default - 0
	DrawParamsNameStr			- Specifies the name of the parameter in the buffer (used for binding of shader variable to buffer data)
	DrawParamsSizeI				- Specifies the size of one parameter in the buffer. Example: for vertex position (3 floats) size should be 3
	DrawParamsOffsetI			- Specifies the offset of parameter in the buffer (in bytes)
	                              Example: for first parameter offset is 0. For second (if 1st parameter uses 3 floats) it is 12
	DrawParamsCountI			- Total number of specified vertex binding parameters [read-only]

	*/
		ComputeBufElem = 1000,
		DrawParamsElem,
		CompBufDataSizeI,
		CompBufDrawableI,
		DrawParamsNameStr,
		DrawParamsSizeI,
		DrawParamsOffsetI,
		DrawParamsCountI
};

enum NodeTypes
{
	/*	Enum: NodeTypes
			The available scene node types.
		
		Undefined  - An undefined node type, returned by getNodeType in case of error
		Group      - Group of different scene nodes
		Model      - 3D model with optional skeleton
		Mesh       - Subgroup of a model with triangles of one material
		Joint      - Joint for skeletal animation
		Light      - Light source
		Camera     - Camera giving view on scene
		Emitter    - Particle system emitter
		Compute	   - Compute node, used for drawing compute results
	*/
		Undefined = 0,
		Group,
		Model,
		Mesh,
		Joint,
		Light,
		Camera,
		Emitter,
		Compute
};

enum NodeFlags
{
	/*	Enum: NodeFlags
			The available scene node flags.

		NoDraw         - Excludes scene node from all rendering
		NoCastShadow   - Excludes scene node from list of shadow casters
		NoRayQuery     - Excludes scene node from ray intersection queries
		Inactive       - Deactivates scene node so that it is completely ignored
		                 (combination of all flags above)
	*/
		NoDraw = 1,
		NoCastShadow = 2,
		NoRayQuery = 4,
		Inactive = 7  // NoDraw | NoCastShadow | NoRayQuery
};

enum NodeParams
{
	/*	Enum: NodeParams
			The available scene node parameters.

		NameStr        - Name of the scene node
		AttachmentStr  - Optional application-specific meta data for a node encapsulated
		                 in an 'Attachment' XML string
	*/
		NameStr = 1,
		AttachmentStr
};


enum Model
{
	/*	Enum: Model
			The available Model node parameters

		GeoResI      - Geometry resource used for the model
		SWSkinningI  - Enables or disables software skinning (default: 0)
		LodDist1F    - Distance to camera from which on LOD1 is used (default: infinite)
		               (must be a positive value larger than 0.0)
		LodDist2F    - Distance to camera from which on LOD2 is used
		               (may not be smaller than LodDist1) (default: infinite)
		LodDist3F    - Distance to camera from which on LOD3 is used
		               (may not be smaller than LodDist2) (default: infinite)
		LodDist4F    - Distance to camera from which on LOD4 is used
		               (may not be smaller than LodDist3) (default: infinite)
		AnimCountI   - Number of active animation stages [read-only]
	*/
		GeoResI = 200,
		SWSkinningI,
		LodDist1F,
		LodDist2F,
		LodDist3F,
		LodDist4F,
		AnimCountI
};

enum Mesh
{
	/*	Enum: Mesh
			The available Mesh node parameters.
		
		MatResI      - Material resource used for the mesh
		BatchStartI  - First triangle index of mesh in Geometry resource of parent Model node [read-only]
		BatchCountI  - Number of triangle indices used for drawing mesh [read-only]
		VertRStartI  - First vertex in Geometry resource of parent Model node [read-only]
		VertREndI    - Last vertex in Geometry resource of parent Model node [read-only]
		LodLevelI    - LOD level of Mesh; the mesh is only rendered if its LOD level corresponds to
		               the model's current LOD level which is calculated based on the LOD distances (default: 0)
		TessellatableI - specify if mesh can be tessellated (default: 0)
	*/
		MatResI = 300,
		BatchStartI,
		BatchCountI,
		VertRStartI,
		VertREndI,
		LodLevelI,
		TessellatableI
};

enum Joint
{
	/*	Enum: Joint
			The available Joint node parameters.

		JointIndexI  - Index of joint in Geometry resource of parent Model node [read-only]
	*/
		JointIndexI = 400
};

enum Light
{
	/*	Enum: Light
			The available Light node parameters.
		
		MatResI             - Material resource used for the light
		RadiusF             - Radius of influence (default: 100.0)
		FovF                - Field of view (FOV) angle (default: 90.0)
		ColorF3             - Diffuse color RGB (default: 1.0, 1.0, 1.0)
		ColorMultiplierF    - Diffuse color multiplier for altering intensity, mainly useful for HDR (default: 1.0)
		ShadowMapCountI     - Number of shadow maps used for light source (values: 0, 1, 2, 3, 4; default: 0)]
		ShadowSplitLambdaF  - Constant determining segmentation of view frustum for Parallel Split Shadow Maps (default: 0.5)
		ShadowMapBiasF      - Bias value for shadow mapping to reduce shadow acne (default: 0.005)
		LightingContextStr  - Name of shader context used for computing lighting
		ShadowContextStr    - Name of shader context used for generating shadow map
	*/
		MatResI = 500,
		RadiusF,
		FovF,
		ColorF3,
		ColorMultiplierF,
		ShadowMapCountI,
		ShadowSplitLambdaF,
		ShadowMapBiasF,
		LightingContextStr,
		ShadowContextStr
};

enum Camera
{
	/*	Enum: Camera
			The available Camera node parameters.
		
		PipeResI         - Pipeline resource used for rendering
		OutTexResI       - 2D Texture resource used as output buffer (can be 0 to use main framebuffer) (default: 0)
		OutBufIndexI     - Index of the output buffer for stereo rendering (values: 0 for left eye, 1 for right eye) (default: 0)
		LeftPlaneF       - Coordinate of left plane relative to near plane center (default: -0.055228457)
		RightPlaneF      - Coordinate of right plane relative to near plane center (default: 0.055228457)
		BottomPlaneF     - Coordinate of bottom plane relative to near plane center (default: -0.041421354f)
		TopPlaneF        - Coordinate of top plane relative to near plane center (default: 0.041421354f)
		NearPlaneF       - Distance of near clipping plane (default: 0.1)
		FarPlaneF        - Distance of far clipping plane (default: 1000)
		ViewportXI       - Position x-coordinate of the lower left corner of the viewport rectangle (default: 0)
		ViewportYI       - Position y-coordinate of the lower left corner of the viewport rectangle (default: 0)
		ViewportWidthI   - Width of the viewport rectangle (default: 320)
		ViewportHeightI  - Height of the viewport rectangle (default: 240)
		OrthoI           - Flag for setting up an orthographic frustum instead of a perspective one (default: 0)
		OccCullingI      - Flag for enabling occlusion culling (default: 0)
	*/
		PipeResI = 600,
		OutTexResI,
		OutBufIndexI,
		LeftPlaneF,
		RightPlaneF,
		BottomPlaneF,
		TopPlaneF,
		NearPlaneF,
		FarPlaneF,
		ViewportXI,
		ViewportYI,
		ViewportWidthI,
		ViewportHeightI,
		OrthoI,
		OccCullingI
};

enum Emitter
{
	/*	Enum: Emitter
			The available Emitter node parameters.
		
		MatResI        - Material resource used for rendering
		PartEffResI    - ParticleEffect resource which configures particle properties
		MaxCountI      - Maximal number of particles living at the same time
		RespawnCountI  - Number of times a single particle is recreated after dying (-1 for infinite)
		DelayF         - Time in seconds before emitter begins creating particles (default: 0.0)
		EmissionRateF  - Maximal number of particles to be created per second (default: 0.0)
		SpreadAngleF   - Angle of cone for random emission direction (default: 0.0)
		ForceF3        - Force vector XYZ applied to particles (default: 0.0, 0.0, 0.0)
	*/
		MatResI = 700,
		PartEffResI,
		MaxCountI,
		RespawnCountI,
		DelayF,
		EmissionRateF,
		SpreadAngleF,
		ForceF3
};

enum ComputeNode
{
	/*	Enum: ComputeNode
	The available compute node parameters.

	MatResI        - Material resource used for rendering
	CompBufResI    - Compute buffer resource that is used as data storage
	AABBMinF       - Minimum of the node's AABB (should be set separately for x, y, z components)
	AABBMaxF       - Maximum of the node's AABB (should be set separately for x, y, z components)
	DrawTypeI	   - Specifies how to draw data in the buffer. 0 - Triangles, 1 - Lines, 2 - Points
	ElementsCountI - Specifies number of elements to draw (Example: for 1000 points - 1000, for 10 triangles - 10)

	*/
		MatResI = 800,
		CompBufResI,
		AABBMinF,
		AABBMaxF,
		DrawTypeI,
		ElementsCountI
};

enum ModelUpdateFlags
{
	/*	Enum: ModelUpdateFlags
			The available flags for UpdateModel.
		
		Animation  - Apply animation
		Geometry   - Apply morphers and software skinning
	*/
		Animation = 1,
		Geometry = 2
};


/* Group: Basic functions */
/* Function: GetVersionString
		Returns the engine version string.
	
	Details:
		This function returns a pointer to a string containing the current version of Horde3D.
	
	Parameters:
		none
		
	Returns:
		pointer to the version string
*/
const char *GetVersionString();

/* Function: CheckExtension
		Checks if an extension is part of the engine library.
	
	Details:
		This function checks if a specified extension is contained in the DLL/shared object of the engine.
	
	Parameters:
		extensionName  - name of the extension
		
	Returns:
		true if extension is implemented, otherwise false
*/
bool CheckExtension( const char *extensionName );

/* Function: GetError
		Checks if an error occured.
	
	Details:
		This function checks if an error occured in a previous API function call. If an error
		flag is set, the function resets the flag and returns true. The function will solely
		report errors that originate from a violated precondition, like an invalid parameter
		that is passed to an API function. Errors that happen during the execution of a function,
		for example failure of initializing the engine due to a missing hardware feature, can
		be catched by checking the return value of the corresponding API function.
		More information about the error can be retrieved by checking the message queue,
		provided that the message level is set accordingly.
	
	Parameters:
		none
		
	Returns:
		true in there was an error, otherwise false
*/
bool GetError();

/* Function: Init
		Initializes the engine.
	
	Details:
		This function initializes the graphics engine and makes it ready for use. It has to be the
		first call to the engine except for getVersionString. In order to successfully initialize
		the engine the calling application must provide a valid OpenGL context. The function can be
		called several times on different rendering contexts in order to initialize them.
	
	Parameters:
		deviceType - type of the render device
		
	Returns:
		true in case of success, otherwise false
*/
bool Init( RenderDevice deviceType );

/* Function: Release
		Releases the engine.
	
	Details:
		This function releases the engine and frees all objects and associated memory. It should be
		called when the application is destroyed.
	
	Parameters:
		none
		
	Returns:
		nothing
*/
void Release();

/* Function: Compute
		Asynchronous processing of arbitrary data on GPU.

	Details:
		This function is used for processing data on GPU via compute shaders. Compute shaders are commonly used in 
		tiled rendering, particles generation, image compression/decompression, some even use them for AI calculation. 
		Calculation results can be stored in a texture or a buffer. 
		Data in buffers can also be used for rendering via Compute Buffer Resource.

	Parameters:
		materialRes  - material that specifies the shader used and various input parameters for compute shader
		context		 - specifies the shader program that will be executed (one shader file may contain a large number of compute shader programs)
		groupX		 - number of work groups in X dimension [1,65535]
		groupY		 - number of work groups in Y dimension [1,65535]
		groupZ		 - number of work groups in Z dimension [1,65535]

	Returns:
		nothing
*/
void Compute( Res materialRes, const char *context, int groupX, int groupY, int groupZ );

/* Function: Render
		Main rendering function.
	
	Details:
		This is the main function of the engine. It executes all the rendering, animation and other
		tasks. The function can be called several times per frame, for example in order to write to different
		output buffers.
	
	Parameters:
		cameraNode  - camera node used for rendering scene
		
	Returns:
		nothing
*/
void Render( Node cameraNode );

/* Function: FinalizeFrame
		Marker for end of frame.
	
	Details:
		This function tells the engine that the current frame is finished and that all
		subsequent rendering operations will be for the next frame.
	
	Parameters:
		none
		
	Returns:
		nothing
*/
void FinalizeFrame();

/* Function: Clear
		Removes all resources and scene nodes.
	
	Details:
		This function removes all nodes from the scene graph except the root node and releases all resources.
	
		*Warning: All resource and node IDs are invalid after calling this function*
	
	Parameters:
		none
		
	Returns:
		nothing
*/
void Clear();


// --- General functions ---
/* Function: GetMessage
		Gets the next message from the message queue.
	
	Details:
		This function returns the next message string from the message queue and writes additional information
		to the specified variables. If no message is left over in the queue an empty string is returned.
	
	Parameters:
		level  - pointer to variable for storing message level indicating importance (can be NULL)
		time   - pointer to variable for storing time when message was added (can be NULL)
		
	Returns:
		message string or empty string if no message is in queue
*/
const char *GetMessage( int *level, float *time );

/* Function: GetOption
		Gets an option parameter of the engine.
	
	Details:
		This function gets a specified option parameter and returns its value.
	
	Parameters:
		param  - option parameter
		
	Returns:
		current value of the specified option parameter
*/
float GetOption( Options param );

/* Function: SetOption
		Sets an option parameter for the engine.
	
	Details:
		This function sets a specified option parameter to a specified value.
	
	Parameters:
		param  - option parameter
		value  - value of the option parameter
		
	Returns:
		true if the option could be set to the specified value, otherwise false
*/
bool SetOption( Options param, float value );

/* Function: GetStat
		Gets a statistic value of the engine.
	
	Details:
		This function returns the value of the specified statistic. The reset flag makes it possible
		to reset the statistic value after reading.
	
	Parameters:
		param  - statistic parameter
		reset  - flag specifying whether statistic value should be reset
		
	Returns:
		current value of the specified statistic parameter
*/
float GetStat( Stats param, bool reset );

/* Function: GetDeviceCapabilities
		Checks whether GPU supports a certain feature.

	Details:
		This function returns a value, indicating the support of a certain GPU capability.

	Parameters:
		param  - requested GPU feature

	Returns:
		1, if feature is supported, 0 otherwise
*/
float GetDeviceCapabilities( DeviceCapabilities param );

/* Function: ShowOverlays
		Displays overlays on the screen.
	
	Details:
		This function displays one or more overlays with a specified material and color.
		An overlay is a screen-space quad that can be used to render 2D GUI elements. The overlay coordinate
		system has its origin (0, 0) at the top-left corner of the screen and its maximum (aspect, 1)
		at the bottom-right corner. As the x coordinate of the maximum corresponds to the aspect ratio
		of the viewport, the size of overlays can always be the same, even when different screen formats
		(standard 4:3, widescreen 16:9, etc.) are used. Texture coordinates are using a system where the
		coordinates (0, 0) correspond to the lower left corner of the image.
		Overlays are drawn in the order in which they are pushed using this function. Overlays with
		the same state will be batched together, so it can make sense to group overlays that have the
		same material, color and flags in order to achieve best performance.
		Note that the overlays have to be removed manually using the function ClearOverlays.
	
	Parameters:
		verts                   - vertex data (x, y, u, v), interpreted as quads
		vertCount               - number of vertices (must be multiple of 4)
		colR, colG, colB, colA  - color (and transparency) of overlays
		materialRes             - material resource used for rendering
		flags                   - overlay flags (reserved for future use)
		
	Returns:
		nothing
*/
void ShowOverlays( const float *verts, int vertCount, float colR, float colG, float colB,
                          float colA, Res materialRes, int flags );

/* Function: ClearOverlays
		Removes all overlays.
	
	Details:
		This function removes all overlays that were added with ShowOverlays.
	
	Parameters:
		none
		
	Returns:
		nothing
*/
void ClearOverlays();


/* Group: General resource management functions */
/* Function: GetResType
		Returns the type of a resource.
	
	Details:
		This function returns the type of a specified resource. If the resource handle is invalid,
		the function returns the resource type 'Unknown'.
	
	Parameters:
		res  - handle to the resource
		
	Returns:
		type of the resource
*/
int GetResType( Res res );

/* Function: GetResName
		Returns the name of a resource.
	
	Details:
		This function returns a pointer to the name of a specified resource. If the resource handle
		is invalid, the function returns an empty string.

		*Important Note: The pointer is const and allows only read access to the data. Do never try to modify the
		data of the pointer since that can corrupt the engine's internal states!*
	
	Parameters:
		res  - handle to the resource
		
	Returns:
		name of the resource or empty string in case of failure
*/
const char *GetResName( Res res );

/* Function: GetNextResource
		Returns the next resource of the specified type.
	
	Details:
		This function searches the next resource of the specified type and returns its handle.
		The search begins after the specified start handle. If a further resource of the queried type
		does not exist, a zero handle is returned. The function can be used to iterate over all
		resources of a given type by using as start the return value of the previous iteration step.
		The first iteration step should start at 0 and iteration can be ended when the function returns 0.
	
	Parameters:
		type   - type of resource to be searched (ResTypes::Undefined for all types)
		start  - resource handle after which the search begins (can be 0 for beginning of resource list)
		
	Returns:
		handle to the found resource or 0 if it does not exist
*/
Res GetNextResource( int type, Res start );

/* Function: FindResource
		Finds a resource and returns its handle.
	
	Details:
		This function searches the resource of the specified type and name and returns its handle. If
		the resource is not available in the resource manager a zero handle is returned.
	
	Parameters:
		type  - type of the resource
		name  - name of the resource
		
	Returns:
		handle to the resource or 0 if not found
*/
Res FindResource( int type, const char *name );

/* Function: AddResource
		Adds a resource.
	
	Details:
		This function tries to add a resource of a specified type and name to the resource manager. If
		a resource of the same type and name is already existing, the handle to the existing resource is returned
		instead of creating a new one and the user reference count of the resource is increased.
	
	Parameters:
		type   - type of the resource
		name   - name of the resource
		flags  - flags used for creating the resource
		
	Returns:
		handle to the resource to be added or 0 in case of failure
*/
Res AddResource( int type, const char *name, int flags );

/* Function: CloneResource
		Duplicates a resource.
	
	Details:
		This function duplicates a specified resource. In the cloning process a new resource with the
		specified name is added to the resource manager and filled with the data of the specified source
		resource. If the specified name for the new resource is already in use, the function fails and
		returns 0. If the name string is empty, a unique name for the resource is generated automatically.
	
	Parameters:
		sourceRes  - handle to resource to be cloned
		name       - name of new resource (can be empty for auto-naming)
		
	Returns:
		handle to the cloned resource or 0 in case of failure
*/
Res CloneResource( Res sourceRes, const char *name );

/* Function: RemoveResource
		Removes a resource.
	
	Details:
		This function decreases the user reference count of a specified resource. When the user reference
		count is zero and there are no internal references, the resource can be released and removed using
		the API fuction releaseUnusedResources.
	
	Parameters:
		res	- handle to the resource to be removed
		
	Returns:
		the number of references that the application is still holding after removal or -1 in case of an error
*/
int RemoveResource( Res res );

/* Function: IsResLoaded
		Checks if a resource is loaded.
	
	Details:
		This function checks if the specified resource has been successfully loaded.
	
	Parameters:
		res  - handle to the resource to be checked
		
	Returns:
		true if resource is loaded, otherwise or in case of failure false
*/
bool IsResLoaded( Res res );

/* Function: LoadResource
		Loads a resource.
	
	Details:
		This function loads data for a resource that was previously added to the resource manager.
		If data is a NULL-pointer the resource manager is told that the resource doesn't have any data
		(e.g. the corresponding file was not found). In this case, the resource remains in the unloaded state
		but is no more returned when querying unloaded resources. When the specified resource is already loaded,
		the function returns false.
	
	Parameters:
		res   - handle to the resource for which data will be loaded
		data  - pointer to the data to be loaded
		size  - size of the data block
		
	Returns:
		true in case of success, otherwise false
*/
bool LoadResource( Res res, const char *data, int size );

/* Function: UnloadResource
		Unloads a resource.
	
	Details:
		This function unloads a previously loaded resource and restores the default values
		it had before loading. The state is set back to unloaded which makes it possible to load
		the resource again.
	
	Parameters:
		res  - handle to resource to be unloaded
		
	Returns:
		nothing
*/
void UnloadResource( Res res );


/* Function: GetResElemCount
		Gets the number of elements in a resource.
	
	Details:
		This function returns how many elements of the specified element type a specified
		resource has.
	
	Parameters:
		res      - handle to the resource to be accessed
		elem     - element type
		
	Returns:
		number of elements
*/
int GetResElemCount( Res res, int elem );

/* Function: FindResElem
		Finds a resource element with the specified property value.
	
	Details:
		This function searches in a specified resource for the first element of the specified
		type that has the property with the specified name set to the specified search value.
		If such element is found, its index is returned, otherwise the function returns -1. All
		string comparisons done for the search are case-sensitive.
	
	Parameters:
		res      - handle to the resource to be accessed
		elem     - element type
		param    - parameter name
		value    - parameter value to be searched for
		
	Returns:
		index of element or -1 if element not found
*/
int FindResElem( Res res, int elem, int param, const char *value );

/* Function: GetResParamI
		Gets an integer property of a resource element.
	
	Details:
		This function returns a specified property of the specified resource element.
		The property must be of the type int.
	
	Parameters:
		res      - handle to the resource to be accessed
		elem     - element type
		elemIdx  - index of element
		param    - parameter to be accessed
		
	Returns:
		value of the parameter
*/
int GetResParamI( Res res, int elem, int elemIdx, int param );

/* Function: SetResParamI
		Sets an integer property of a resource element.
	
	Details:
		This function sets a specified property of the specified resource element to the
		specified value. The property must be of the type int.
	
	Parameters:
		res      - handle to the resource to be modified
		elem     - element type
		elemIdx  - index of element
		param    - parameter to be modified
		value    - new value for the specified parameter
		
	Returns:
		 nothing
*/
void SetResParamI( Res res, int elem, int elemIdx, int param, int value );

/* Function: GetResParamF
		Gets a float property of a resource element.
	
	Details:
		This function returns the specified component of the specified resource element property.
		The property must be of the type float. Float properties can have several indexed components,
		for example the x, y and z components of a vector.
	
	Parameters:
		res      - handle to the resource to be accessed
		elem     - element type
		elemIdx  - index of element
		param    - parameter to be accessed
		compIdx  - component of the parameter to be accessed
		
	Returns:
		value of the parameter
*/
float GetResParamF( Res res, int elem, int elemIdx, int param, int compIdx );

/* Function: SetResParamF
		Sets a float property of a resource element.
	
	Details:
		This function sets the specified component of the specified resource element property to the
		specified value. The property must be of the type float.
	
	Parameters:
		res      - handle to the resource to be modified
		elem     - element type
		elemIdx  - index of element
		param    - parameter to be modified
		compIdx  - component of the parameter to be modified
		value    - new value for the specified parameter
		
	Returns:
		nothing
*/
void SetResParamF( Res res, int elem, int elemIdx, int param, int compIdx, float value );

/* Function: GetResParamStr
		Gets a string property of a resource element.
	
	Details:
		This function returns a specified property of the specified resource element.
		The property must be of the type string (const char *).

		*Important Note: The pointer is const and allows only read access to the data. Do never try to modify the
		data of the pointer since that can corrupt the engine's internal states!*
	
	Parameters:
		res      - handle to the resource to be accessed
		elem     - element type
		elemIdx  - index of element
		param    - parameter to be accessed
		
	Returns:
		value of the property or empty string if no such property exists
*/
const char *GetResParamStr( Res res, int elem, int elemIdx, int param );

/* Function: SetResParamStr
		Sets a string property of a resource element.
	
	Details:
		This function sets a specified property of the specified resource element to the
		specified value. The property must be of the type string (const char *).
	
	Parameters:
		res      - handle to the resource to be modified
		elem     - element type
		elemIdx  - index of element
		param    - parameter to be modified
		value    - new value for the specified parameter
		
	Returns:
		nothing
*/
void SetResParamStr( Res res, int elem, int elemIdx, int param, const char *value );

/* Function: MapResStream
		Maps the stream of a resource element.
	
	Details:
		This function maps the specified stream of a specified resource element and returns a
		pointer to the stream data. The required access to the data can be specified with the read
		write parameters. If read is false, the pointer will usually not contain meaningful data.
		Not all resource streams can be mapped with both read and write access. If it is not
		possible to map the stream, the function will return a NULL pointer. A mapped stream should
		be unmapped again as soon as possible but always before subsequent API calls are made. It
		is only possible to map one stream per resource at a time.
	
	Parameters:
		res      - handle to the resource to be mapped
		elem     - element type
		elemIdx  - index of element
		stream   - stream to be mapped
		read     - flag indicating whether read access is required
		write    - flag indicating whether write access is required
		
	Returns:
		pointer to stream data or NULL if stream cannot be mapped
*/
void *MapResStream( Res res, int elem, int elemIdx, int stream, bool read, bool write );

/* Function: UnmapResStream
		Unmaps a previously mapped resource stream.
	
	Details:
		This function unmaps a resource stream that has been mapped before.
	
	Parameters:
		res  - handle to the resource to be unmapped
		
	Returns:
		nothing
*/
void UnmapResStream( Res res );

/* Function: QueryUnloadedResource
		Returns handle to an unloaded resource.
	
	Details:
		This function looks for a resource that is not yet loaded and returns its handle.
		If there are no unloaded resources or the zero based index specified is greater than the number
		of the currently unloaded resources, 0 is returned.
	
	Parameters:
		index  - index of unloaded resource within the internal list of unloaded resources (starting with 0) 
		
	Returns:
		handle to an unloaded resource or 0
*/
Res QueryUnloadedResource( int index );

/* Function: ReleaseUnusedResources
		Frees resources that are no longer used.
	
	Details:
		This function releases resources that are no longer used. Unused resources were either told
		to be released by the user calling removeResource or are no more referenced by any other
		engine objects.
	
	Parameters:
		none
		
	Returns:
		nothing
*/
void ReleaseUnusedResources();


/* Group: Specific resource management functions */
/* Function: CreateTexture
		Creates a Texture resource.
	
	Details:
		This function tries to create and add a Texture resource with the specified name to the resource
		manager. If a Texture resource with the same name is already existing, the function fails. The
		texture is initialized with the specified dimensions and the resource is declared as loaded. This
		function is especially useful to create dynamic textures (e.g. for displaying videos) or output buffers
		for render-to-texture.
	
	Parameters:
		name        - name of the resource
		width       - width of the texture image
		height      - height of the texture image
		fmt         - texture format (see stream formats)
		flags       - flags used for creating the resource
		
	Returns:
		handle to the created resource or 0 in case of failure
*/
Res CreateTexture( const char *name, int width, int height, int fmt, int flags );

/* Function: SetShaderPreambles
		Sets preambles of all Shader resources.
	
	Details:
		This function defines a header that is inserted at the beginning of all shaders. The preamble
		is used when a shader is compiled, so changing it will not affect any shaders that are already
		compiled. The preamble is useful for setting platform-specific defines that can be employed for
		creating several shader code paths, e.g. for supporting different hardware capabilities.
		Based on render device requirements, engine may internally set shader preambles. OpenGL 4 render device
		sets shader preambles to specify minimum version, required to compile a shader program of required type.
	
	Parameters:
		vertPreamble  - preamble text of vertex shaders (default: empty string)
		fragPreamble  - preamble text of fragment shaders (default: empty string)
		geomPreamble  - preamble text of geometry shaders (default: empty string)
		tessControlPreamble - preamble text of tessellation control shaders (default: empty string)
		tessEvalPreamble - preamble text of tessellation evaluation shaders (default: empty string)
		computePreamble - preamble text of compute shaders (default: empty string)

	Returns:
		nothing
*/
void SetShaderPreambles( const char *vertPreamble, const char *fragPreamble, const char *geomPreamble,
								const char *tessControlPreamble, const char *tessEvalPreamble, const char *computePreamble );

/* Function: SetMaterialUniform
		Sets a shader uniform of a Material resource.
	
	Details:
		This function sets the specified shader uniform of the specified material to the specified values.
	
	Parameters:
		materialRes  - handle to the Material resource to be accessed
		name         - name of the uniform as defined in Material resource
		a, b, c, d   - values of the four components
		
	Returns:
		true if uniform was found, otherwise false
*/
bool SetMaterialUniform( Res materialRes, const char *name, float a, float b, float c, float d );

/* Function: ResizePipelineBuffers
		Changes the size of the render targets of a pipeline.
	
	Details:
		This function sets the base width and height which affects render targets with relative (in percent) size 
		specification. Changing the base size is usually desired after engine initialization and when the window
		is being resized. Note that in case several cameras use the same pipeline resource instance, the change
		will affect all cameras.
	
	Parameters:
	    pipeRes  - the pipeline resource instance to be changed
		width    - base width in pixels used for render targets with relative size
		height   - base height in pixels used for render targets with relative size
		
	Returns:
		nothing
*/
void ResizePipelineBuffers( Res pipeRes, int width, int height );

/* Function: GetRenderTargetData
		Reads back the pixel data of a render target buffer.
	
	Details:
		This function reads back the pixels of a specified render target. If no pipeline resource is specified,
		the color data of the backbuffer is read back as RGBA float. Otherwise, the specified buffer of the
		specified render target is read back and stored in dataBuffer as RGBA float values.
		To compute the required size of the output buffer to which the data is written, the function can be called
		with a NULL pointer for dataBuffer and pointers to variables where the buffer width, height and the number
		of components will be stored.
		As this function has a considerable performance overhead, it is only intended for debugging purposes and screenshots.
		For more information about the render buffers, refer to the Pipeline documentation.
		
	Parameters:
		pipelineRes  - handle to pipeline resource (0 for backbuffer)
		targetName   - name of render target to be accessed (ignored for backbuffer)
		bufIndex     - index of buffer to be accessed (32 for depth buffer)
		width        - pointer to variable where the width of the buffer will be stored (can be NULL)
		height       - pointer to variable where the height of the buffer will be stored (can be NULL)
		compCount    - pointer to variable where the number of components will be stored (can be NULL)
		dataBuffer   - pointer to array where the pixel data will be stored (can be NULL)
		bufferSize   - size of dataBuffer array in bytes
		
	Returns:
		true if specified render target could be found, otherwise false
*/
bool GetRenderTargetData( Res pipelineRes, const char *targetName, int bufIndex,
                                 int *width, int *height, int *compCount, void *dataBuffer, int bufferSize );


/* Group: General scene graph functions */
/* Function: GetNodeType
		Returns the type of a scene node.
	
	Details:
		This function returns the type of a specified scene node. If the node handle is invalid,
		the function returns the node type 'Unknown'.
	
	Parameters:
		node  - handle to the scene node
		
	Returns:
		type of the scene node
*/
int GetNodeType( Node node );
	
/* Function: GetNodeParent
		Returns the parent of a scene node.
	
	Details:
		This function returns the handle to the parent node of a specified scene node. If the specified
		node handle is invalid or the root node, 0 is returned.
	
	Parameters:
		node  - handle to the scene node
		
	Returns:
		handle to parent node or 0 in case of failure
*/
Node GetNodeParent( Node node );


/* Function: SetNodeParent
		Relocates a node in the scene graph.
	
	Details:
		This function relocates a scene node. It detaches the node from its current parent and attaches
		it to the specified new parent node. If the attachment to the new parent is not possible, the
		function returns false. Relocation is not possible for the RootNode.
	
	Parameters:
		node    - handle to the scene node to be relocated
		parent  - handle to the new parent node
		
	Returns:
		true if node could be relocated, otherwise false
*/
bool SetNodeParent( Node node, Node parent );

/* Function: GetNodeChild
		Returns the handle to a child node.
	
	Details:
		This function looks for the n-th (index) child node of a specified node and returns its handle. If the child
		doesn't exist, the function returns 0.
	
	Parameters:
		node   - handle to the parent node
		index  - index of the child node
		
	Returns:
		handle to the child node or 0 if child doesn't exist
*/
Node GetNodeChild( Node node, int index );



/* Function: AddNodes
		Adds nodes from a SceneGraph resource to the scene.
	
	Details:
		This function creates several new nodes as described in a SceneGraph resource and
		attaches them to a specified parent node. If an invalid scenegraph resource is specified
		or the scenegraph resource is unloaded, the function returns 0.
	
	Parameters:
		parent         - handle to parent node to which the root of the new nodes will be attached
		sceneGraphRes  - handle to loaded SceneGraph resource
		
	Returns:
		handle to the root of the created nodes or 0 in case of failure
*/
Node AddNodes( Node parent, Res sceneGraphRes );

/* Function: RemoveNode
		Removes a node from the scene.
	
	Details:
		This function removes the specified node and all of it's children from the scene.
	
	Parameters:
		node  - handle to the node to be removed
		
	Returns:
		nothing
*/
void RemoveNode( Node node );

/* Function: CheckNodeTransFlag
		Checks if a scene node has been transformed by the engine.
	
	Details:
		This function checks if a scene node has been transformed by the engine since the last
		time the transformation flag was reset. Therefore, it stores a flag that is set to true when a
		setTransformation function is called explicitely by the application or when the node transformation
		has been updated by the animation system. The function also makes it possible to reset the
		transformation flag.
	
	Parameters:
		node   - handle to the node to be accessed
		reset  - flag indicating whether transformation flag shall be reset
		
	Returns:
		true if node has been transformed, otherwise false
*/
bool CheckNodeTransFlag( Node node, bool reset );

/* Function: GetNodeTransform
		Gets the relative transformation of a node.
	
	Details:
		This function gets the translation, rotation and scale of a specified scene node object. The
		coordinates are in local space and contain the transformation of the node relative to its parent.
	
	Parameters:
		node        - handle to the node which will be accessed
		tx, ty, tz  - pointers to variables where translation of the node will be stored (can be NULL)
		rx, ry, rz  - pointers to variables where rotation of the node in Euler angles
		              will be stored (can be NULL)
		sx, sy, sz  - pointers to variables where scale of the node will be stored (can be NULL)
		
	Returns:
		nothing
*/
void GetNodeTransform( Node node, float *tx, float *ty, float *tz,
                              float *rx, float *ry, float *rz, float *sx, float *sy, float *sz );

/* Function: SetNodeTransform
		Sets the relative transformation of a node.
	
	Details:
		This function sets the relative translation, rotation and scale of a specified scene node object.
		The coordinates are in local space and contain the transformation of the node relative to its parent.
	
	Parameters:
		node        - handle to the node which will be modified
		tx, ty, tz  - translation of the node
		rx, ry, rz  - rotation of the node in Euler angles
		sx, sy, sz  - scale of the node
		
	Returns:
		nothing
*/
void SetNodeTransform( Node node, float tx, float ty, float tz,
                              float rx, float ry, float rz, float sx, float sy, float sz );

/* Function: GetNodeTransMats
		Returns the transformation matrices of a node.
	
	Details:
		This function stores a pointer to the relative and absolute transformation matrices
		of the specified node in the specified pointer varaibles.
	
	Parameters:
		node    - handle to the scene node to be accessed
		relMat  - pointer to a variable where the address of the relative transformation matrix will be stored
		          (can be NULL if matrix is not required)
		absMat  - pointer to a variable where the address of the absolute transformation matrix will be stored
		          (can be NULL if matrix is not required)
		
		
	Returns:
		nothing
*/
void GetNodeTransMats( Node node, const float **relMat, const float **absMat );

/* Function: SetNodeTransMat
		Sets the relative transformation matrix of a node.
	
	Details:
		This function sets the relative transformation matrix of the specified scene node. It is basically the
		same as setNodeTransform but takes directly a matrix instead of individual transformation parameters.
	
	Parameters:
		node    - handle to the node which will be modified
		mat4x4  - pointer to a 4x4 matrix in column major order
		
	Returns:
		nothing
*/
void SetNodeTransMat( Node node, const float *mat4x4 );

/* Function: GetNodeParamI
		Gets a property of a scene node.
	
	Details:
		This function returns a specified property of the specified node.
		The property must be of the type int or Res.
	
	Parameters:
		node   - handle to the node to be accessed
		param  - parameter to be accessed
		
	Returns:
		value of the parameter
*/
int GetNodeParamI( Node node, int param );

/* Function: SetNodeParamI
		Sets a property of a scene node.
	
	Details:
		This function sets a specified property of the specified node to a specified value.
		The property must be of the type int or Res.
	
	Parameters:
		node   - handle to the node to be modified
		param  - parameter to be modified
		value  - new value for the specified parameter
		
	Returns:
		nothing
*/
void SetNodeParamI( Node node, int param, int value );

/* Function: GetNodeParamF
		Gets a property of a scene node.
	
	Details:
		This function returns a specified property of the specified node. Float properties can have
		several indexed components, for example the x, y and z components of a vector.
		The property must be of the type float.
	
	Parameters:
		node     - handle to the node to be accessed
		param    - parameter to be accessed
		compIdx  - component of the parameter to be accessed
		
	Returns:
		value of the parameter
*/
float GetNodeParamF( Node node, int param, int compIdx );

/* Function: SetNodeParamF
		Sets a property of a scene node.
	
	Details:
		This function sets a specified property of the specified node to a specified value.
		The property must be of the type float.
	
	Parameters:
		node     - handle to the node to be modified
		param    - parameter to be modified
		compIdx  - component of the parameter to be modified
		value    - new value for the specified parameter
		
	Returns:
		nothing
*/
void SetNodeParamF( Node node, int param, int compIdx, float value );

/* Function: GetNodeParamStr
		Gets a property of a scene node.
	
	Details:
		This function returns a specified property of the specified node.
		The property must be of the type string (const char *).

		*Important Note: The pointer is const and allows only read access to the data. Do never try to modify the
		data of the pointer since that can corrupt the engine's internal states!*
	
	Parameters:
		node   - handle to the node to be accessed
		param  - parameter to be accessed
		
	Returns:
		value of the property or empty string if no such property exists
*/
const char *GetNodeParamStr( Node node, int param );

/* Function: SetNodeParamStr
		Sets a property of a scene node.
	
	Details:
		This function sets a specified property of the specified node to a specified value.
		The property must be of the type string (const char *).
	
	Parameters:
		node   - handle to the node to be modified
		param  - parameter to be modified
		value  - new value for the specified parameter
		
	Returns:
		nothing
*/
void SetNodeParamStr( Node node, int param, const char *value );

/* Function: GetNodeFlags
		Gets the scene node flags.

	Details:
		This function returns a bit mask containing the set scene node flags.
	
	Parameters:
		node  - handle to the node to be accessed
		
	Returns:
		flag bitmask
*/
int GetNodeFlags( Node node );

/* Function: SetNodeFlags
		Sets the scene node flags.
	
	Details:
		This function sets the flags of the specified scene node.
	
	Parameters:
		node       - handle to the node to be modified
		flags      - new flag bitmask
		recursive  - specifies whether flags should be applied recursively to all child nodes
		
	Returns:
		nothing
*/
void SetNodeFlags( Node node, int flags, bool recursive );

/* Function: GetNodeAABB
		Gets the bounding box of a scene node.
	
	Details:
		This function stores the world coordinates of the axis aligned bounding box of a specified node in
		the specified variables. The bounding box is represented using the minimum and maximum coordinates
		on all three axes.
	
	Parameters:
		node              - handle to the node which will be accessed
		minX, minY, minZ  - pointers to variables where minimum coordinates will be stored
		maxX, maxY, maxZ  - pointers to variables where maximum coordinates will be stored
		
	Returns:
		nothing
*/
void GetNodeAABB( Node node, float *minX, float *minY, float *minZ,
                         float *maxX, float *maxY, float *maxZ );

/* Function: FindNodes
		Finds scene nodes with the specified properties.
	
	Details:
		This function loops recursively over all children of startNode and adds them to an internal list
		of results if they match the specified name and type. The result list is cleared each time this
		function is called. The function returns the number of nodes which were found and added to the list.
	
	Parameters:
		startNode  - handle to the node where the search begins
		name       - name of nodes to be searched (empty string for all nodes)
		type       - type of nodes to be searched (NodeTypes::Undefined for all types)
		
	Returns:
		number of search results
*/
int FindNodes( Node startNode, const char *name, int type );

/* Function: GetNodeFindResult
		Gets a result from the findNodes query.
	
	Details:
		This function returns the n-th (index) result of a previous findNodes query. The result is the handle
		to a scene node with the poperties specified at the findNodes query. If the index doesn't exist in the
		result list the function returns 0.
	
	Parameters:
		index  - index of search result
		
	Returns:
		handle to scene node from findNodes query or 0 if result doesn't exist
*/
Node GetNodeFindResult( int index );

/* Function: SetNodeUniforms
		Sets per-instance uniform data for a node.

	Details:
		This function sets the custom per-instance uniform data for a node that can be accessed
		from within a shader. The specified number of floats is copied from the specified memory location.
		Currently only Model nodes will store this data.

	Parameters:
		node         - node for which data will be set
		uniformData  - pointer to float array
		count        - number of floats to be copied
		
	Returns:
		nothing
*/
void SetNodeUniforms( Node node, float *uniformData, int count );

/* Function: CastRay
		Performs a recursive ray collision query.
	
	Details:
		This function checks recursively if the specified ray intersects the specified node or one of its children.
		The function finds intersections relative to the ray origin and returns the number of intersecting scene
		nodes. The ray is a line segment and is specified by a starting point (the origin) and a finite direction
		vector which also defines its length. Currently this function is limited to returning intersections with Meshes.
		For Meshes, the base LOD (LOD0) is always used for performing the ray-triangle intersection tests.
	
	Parameters:
		node        - node at which intersection check is beginning
		ox, oy, oz  - ray origin
		dx, dy, dz  - ray direction vector also specifying ray length
		numNearest  - maximum number of intersection points to be stored (0 for all)
		
	Returns:
		number of intersections
	*/
int CastRay( Node node, float ox, float oy, float oz, float dx, float dy, float dz, int numNearest );

/*	Function: GetCastRayResult
		Returns a result of a previous castRay query.

	Details:
		This functions is used to access the results of a previous castRay query. The index is used to access
		a specific result. The intersection data is copied to the specified variables.

	Parameters:
		index         - index of result to be accessed (range: 0 to number of results returned by castRay)
		node          - handle of intersected node
		distance      - distance from ray origin to intersection point
		intersection  - coordinates of intersection point (float[3] array)

	Returns:
		true if index was valid and data could be copied, otherwise false
*/
bool GetCastRayResult( int index, Node *node, float *distance, float *intersection );

/*	Function: CheckNodeVisibility
		Checks if a node is visible.

	Details:
		This function checks if a specified node is visible from the perspective of a specified
		camera. The function always checks if the node is in the camera's frustum. If checkOcclusion
		is true, the function will take into account the occlusion culling information from the previous
		frame (if occlusion culling is disabled the flag is ignored). The flag calcLod determines whether the
		detail level for the node should be returned in case it is visible. The function returns -1 if the node
		is not visible, otherwise 0 (base LOD level) or the computed LOD level.

	Parameters:
		node            - node to be checked for visibility
		cameraNode      - camera node from which the visibility test is done
		checkOcclusion  - specifies if occlusion info from previous frame should be taken into account
		calcLod         - specifies if LOD level should be computed

	Returns:
		computed LOD level or -1 if node is not visible
*/
int CheckNodeVisibility( Node node, Node cameraNode, bool checkOcclusion, bool calcLod );


/* Group: Group-specific scene graph functions */
/* Function: AddGroupNode
		Adds a Group node to the scene.
	
	Details:
		This function creates a new Group node and attaches it to the specified parent node.
	
	Parameters:
		parent  - handle to parent node to which the new node will be attached
		name    - name of the node
		
	Returns:
		handle to the created node or 0 in case of failure
*/
Node AddGroupNode( Node parent, const char *name );


/* Group: Model-specific scene graph functions */
/* Function: AddModelNode
		Adds a Model node to the scene.
	
	Details:
		This function creates a new Model node and attaches it to the specified parent node.
	
	Parameters:
		parent       - handle to parent node to which the new node will be attached
		name         - name of the node
		geometryRes  - Geometry resource used by Model node
		
	Returns:
		handle to the created node or 0 in case of failure
*/
Node AddModelNode( Node parent, const char *name, Res geometryRes );

/* Function: SetupModelAnimStage
		Configures an animation stage of a Model node.
	
	Details:
		This function is used to setup the specified animation stage/slot of the specified Model node.
		
		The function can be used for animation blending and mixing. There is a fixed number of stages
		(by default 16) on which different animations can be played. The start node determines the first node
		(Joint or Mesh) to which the animation is recursively applied. If the start node is an empty string, the
		animation affects all animatable nodes (Joints and Meshes) of the model. If a NULL-handle is used for
		animationRes, the stage is cleared and the currently set animation is removed.

		The layer determines the priority of the animation and how the weights are distributed. See
		SetModelAnimParams for more information.
		
		A simple way to do animation mixing is using additive animations. If a stage is configured to be
		additive, the engine calculates the difference between the current frame and the first frame in the
		animation and adds this delta, scaled by the weight factor, to the current transformation of the joints
		or meshes. Additive animations completely ignore the layer settings. They are only applied by the engine
		if a non-additive animation is assigned to the model as well.
	
	Parameters:
		modelNode     - handle to the Model node to be modified
		stage         - index of the animation stage to be configured
		animationRes  - handle to Animation resource (can be 0)
		layer         - layer id
		startNode     - name of first node to which animation shall be applied (or empty string)
		additive      - flag indicating whether stage is additive
		
	Returns:
		nothing
*/
void SetupModelAnimStage( Node modelNode, int stage, Res animationRes, int layer,
                                 const char *startNode, bool additive );

/* Function: GetModelAnimParams
		Gets the animation stage parameters of a Model node.
	
	Details:
		This function gets the current animation time and weight for a specified stage of the
		specified model. The time corresponds to the frames of the animation and the animation is
		looped if the time is higher than the maximum number of frames in the Animation resource.
		The weight is used for animation blending and determines how much influence the stage has compared
		to the other active stages.
	
	Parameters:
		modelNode  - handle to the Model node to be accessed
		stage      - index of the animation stage to be accessed
		time       - pointer to variable where the time of the animation stage will be stored
                 (can be NULL if not required)
		weight     - pointer to variable where the blend weight of the animation stage will be stored
                 (can be NULL if not required)
		
	Returns:
		nothing
*/
void GetModelAnimParams( Node modelNode, int stage, float *time, float *weight );

/* Function: SetModelAnimParams
		Sets the animation stage parameters of a Model node.
	
	Details:
		This function sets the current animation time and weight for a specified stage of the
		specified model. The time corresponds to the frames of the animation and the animation is
		looped if the time is higher than the maximum number of frames in the Animation resource.
		The weight is used for animation blending and determines how much influence the stage has compared
		to the other active stages. All weights of stages that are on the same layer are normalized.
		Stages with a higher layer id are animated before stages with lower layers. The blend weight
		is distributed across the layers. If the weight sum of a layer is smaller than 1.0, the remaining
		weight is propagated to the next lower layer. So if a layer uses a weight of 100%, the lower layers
		will not get any weight and consequently not contribute to the overall animation.
	
	Parameters:
		modelNode  - handle to the Model node to be modified
		stage      - index of the animation stage to be modified
		time       - new animation time/frame
		weight     - new blend weight
		
	Returns:
		nothing
*/
void SetModelAnimParams( Node modelNode, int stage, float time, float weight );

/* Function: SetModelMorpher
		Sets the weight of a morph target.
	
	Details:
		This function sets the weight of a specified morph target. If the target parameter
		is an empty string the weight of all morph targets in the specified Model node is modified.
		If the specified morph target is not found the function returns false.
	
	Parameters:
		modelNode  - handle to the Model node to be modified
		target     - name of morph target
		weight     - new weight for morph target
		
	Returns:
		true if morph target was found, otherwise false
*/
bool SetModelMorpher( Node modelNode, const char *target, float weight );


/* Function: UpdateModel
		Applies animation and/or geometry updates.
	
	Details:
		This function applies skeletal animation and geometry updates to the specified model, depending on
		the specified update flags. Geometry updates include morph targets and software skinning if enabled.
		If the animation or morpher parameters did not change, the function returns immediately. This function
		has to be called so that changed animation or morpher parameters will take effect.
	
	Parameters:
		modelNode  - handle to the Model node to be updated
		flags      - combination of ModelUpdate flags
		
	Returns:
		nothing
*/
void UpdateModel( Node modelNode, int flags );


/* Group: Mesh-specific scene graph functions */
/* Function: AddMeshNode
		Adds a Mesh node to the scene.
	
	Details:
		This function creates a new Mesh node and attaches it to the specified parent node.
	
	Parameters:
		parent       - handle to parent node to which the new node will be attached
		name         - name of the node
		materialRes  - material resource used by Mesh node
		batchStart   - first triangle index of mesh in Geometry resource of parent Model node
		batchCount   - number of triangle indices used for drawing mesh
		vertRStart   - first vertex in Geometry resource of parent Model node
		vertREnd     - last vertex in Geometry resource of parent Model node
		
	Returns:
		handle to the created node or 0 in case of failure
*/
Node AddMeshNode( Node parent, const char *name, Res materialRes, 
                            int batchStart, int batchCount, int vertRStart, int vertREnd );


/* Group: Joint-specific scene graph functions */
/* Function: AddJointNode
		Adds a Joint node to the scene.
	
	Details:
		This function creates a new Joint node and attaches it to the specified parent node.
	
	Parameters:
		parent      - handle to parent node to which the new node will be attached
		name        - name of the node
		jointIndex  - index of joint in Geometry resource of parent Model node
		
	Returns:
		handle to the created node or 0 in case of failure
*/
Node AddJointNode( Node parent, const char *name, int jointIndex );


/* Group: Light-specific scene graph functions */
/* Function: AddLightNode
		Adds a Light node to the scene.
	
	Details:
		This function creates a new Light node and attaches it to the specified parent node.
		The direction vector of the untransformed light node is pointing along the the negative
		z-axis. The specified material resource can define uniforms and projective textures.
		Furthermore it can contain a shader for doing lighting calculations if deferred shading
		is used. If no material is required the parameter can be zero. The context names
		define which shader contexts are used when rendering shadow maps or doing light calculations for
		forward rendering configurations.
	
	Parameters:
		parent           - handle to parent node to which the new node will be attached
		name             - name of the node
		materialRes      - material resource for light configuration or 0 if not used
		lightingContext  - name of the shader context used for doing light calculations
		shadowContext    - name of the shader context used for doing shadow map rendering
		
	Returns:
		handle to the created node or 0 in case of failure
*/
Node AddLightNode( Node parent, const char *name, Res materialRes,
                             const char *lightingContext, const char *shadowContext );


/* Group: Camera-specific scene graph functions */
/* Function: AddCameraNode
		Adds a Camera node to the scene.
	
	Details:
		This function creates a new Camera node and attaches it to the specified parent node.
	
	Parameters:
		parent       - handle to parent node to which the new node will be attached
		name         - name of the node
		pipelineRes  - pipeline resource used for rendering
		
	Returns:
		handle to the created node or 0 in case of failure
*/
Node AddCameraNode( Node parent, const char *name, Res pipelineRes );

/* Function: SetupCameraView
		Sets the planes of a camera viewing frustum.
	
	Details:
		This function calculates the view frustum planes of the specified camera node using the specified view
		parameters.
	
	Parameters:
		cameraNode  - handle to the Camera node which will be modified
		fov         - field of view (FOV) angle
		aspect      - aspect ratio
		nearDist    - distance of near clipping plane
		farDist     - distance of far clipping plane 
		
	Returns:
		nothing
*/
void SetupCameraView( Node cameraNode, float fov, float aspect, float nearDist, float farDist );

/* Function: GetCameraProjMat
		Gets the camera projection matrix.
	
	Details:
		This function gets the camera projection matrix used for bringing the geometry to
		screen space and copies it to the specified array.
	
	Parameters:
		cameraNode  - handle to Camera node
		projMat     - pointer to float array with 16 elements
		
	Returns:
		nothing
*/
void GetCameraProjMat( Node cameraNode, float *projMat );

/* Function: SetCameraProjMat
		Sets the camera projection matrix.

	Details :
		This function sets the camera projection matrix used for bringing the geometry to
		screen space.

	Parameters :
		cameraNode - handle to Camera node
		projMat - pointer to float array with 16 elements

	Returns :
		nothing
*/

void SetCameraProjMat( Node cameraNode, float *projMat );

/* Group: Emitter-specific scene graph functions */
/* Function: AddEmitterNode
		Adds a Emitter node to the scene.
	
	Details:
		This function creates a new Emitter node and attaches it to the specified parent node.
	
	Parameters:
		parent             - handle to parent node to which the new node will be attached
		name               - name of the node
		materialRes        - handle to Material resource used for rendering
		particleEffectRes  - handle to ParticleEffect resource used for configuring particle properties
		maxParticleCount   - maximal number of particles living at the same time
		respawnCount       - number of times a single particle is recreated after dying (-1 for infinite)
		
		
	Returns:
		handle to the created node or 0 in case of failure
*/
Node AddEmitterNode( Node parent, const char *name, Res materialRes,
                               Res particleEffectRes, int maxParticleCount, int respawnCount );

/* Function: UpdateEmitter
		Advances emitter time and performs particle simulation.
	
	Details:
		This function advances the simulation time of a particle system and performs the particle simulation
		with timeDelta being the time elapsed since the last call of this function. The specified
		node must be an Emitter node.
	
	Parameters:
		emitterNode  - handle to the Emitter node which will be updated
		timeDelta    - time delta in seconds
		
	Returns:
		nothing
*/
void UpdateEmitter( Node emitterNode, float timeDelta );

/* Function: HasEmitterFinished
		Checks if an Emitter node is still alive.
	
	Details:
		This function checks if a particle system is still active and has living particles or
		will spawn new particles. The specified node must be an Emitter node. The function can be
		used to check when a not infinitely running emitter for an effect like an explosion can be
		removed from the scene.
	
	Parameters:
		emitterNode  - handle to the Emitter node which is checked
		
	Returns:
		true if Emitter will no more emit any particles, otherwise or in case of failure false
*/
bool HasEmitterFinished( Node emitterNode );


/* Group: Compute-specific scene graph functions */
/* Function: AddComputeNode
		Adds a Compute node to the scene.

	Details:
		This function creates a new Compute node and attaches it to the specified parent node.
		Compute node is used for drawing results of compute shader work. 

	Parameters:
		parent             - handle to parent node to which the new node will be attached
		name               - name of the node
		materialRes        - handle to Material resource used for rendering
		compBufferRes	   - handle to ComputeBuffer resource that is used as vertex storage
		drawType		   - specifies how to treat data in the compute buffer. 0 - Triangles, 1 - Lines, 2 - Points
		elementsCount	   - number of elements that need to be drawn
		
	Returns:
		handle to the created node or 0 in case of failure
*/
Node AddComputeNode( Node parent, const char *name, Res materialRes, Res compBufferRes, int drawType, int elementsCount );
