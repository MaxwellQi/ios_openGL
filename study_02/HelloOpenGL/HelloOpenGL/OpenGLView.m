//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by qi on 30/11/2017.
//  Copyright © 2017 tvu. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"

@implementation OpenGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    
}

- (void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer
{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)render
{
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    GLfloat vertices[] = {
        0.0f,0.5f,0.0f,
        -0.5f,-0.5f,0.0f,
        0.5f,-0.5f,0.0f
    };
    
    // Load the vertex data
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);

    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];

        [self setupProgram];
        
        [self render];
    }
    return self;
}

// use ver and frag
- (GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType
{
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shaderHandle, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"%@",messageString);
        exit(1);
    }
    return shaderHandle;
}

- (void)compileShaders
{
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@",messageString);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}


- (void)setupProgram
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"SimpleVertex" ofType:@"glsl"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"SimpleFragment" ofType:@"glsl"];
    GLuint vertexShader = [GLESUtils loadShader:GL_VERTEX_SHADER withFilepath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadShader:GL_FRAGMENT_SHADER withFilepath:fragmentShaderPath];
    
    // Create program, attach shaders.
    _programHandle = glCreateProgram();
    if (!_programHandle) {
        NSLog(@"Failed to create program.");
        return;
    }
    
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    
    //  Link program
    glLinkProgram(_programHandle);
    
    // check the link status
    GLint linked;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(_programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(_programHandle, infoLen, NULL, infoLog);
            NSLog(@"Error linking program:\n%s\n", infoLog );
            
            free (infoLog );
        }
        glDeleteProgram(_programHandle);
        _programHandle = 0;
        return;
    }
    
    glUseProgram(_programHandle);
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
}


@end
