//
//  GLESUtils.h
//  HelloOpenGL
//
//  Created by qi on 30/11/2017.
//  Copyright © 2017 tvu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface GLESUtils : NSObject

// Create a shader object, load the shader source string, and compile the shader.
+ (GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;
+ (GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilePath;
@end
