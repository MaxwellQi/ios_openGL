attribute vec4 Position;
attribute vec4 SourceColor;

void main(void){
    DestinationColor = SourceColor;
    gl_Position = Position;
}
