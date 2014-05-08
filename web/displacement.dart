import 'dart:core';
import 'dart:html';
import 'dart:math';

import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';

Scene scene;
PerspectiveCamera camera;
WebGLRenderer renderer;

double fov = 30.0;
ShaderMaterial material;
Mesh mesh;
Random rand = new Random();
var attributes;
var displacement;
var uniforms;
var amplitude;

void main()
{
  init();
  window.animationFrame.then(render);
}

void init()
{
  scene = new Scene();
  
  displacement = new Attribute.float();
  attributes = { "displacement" : displacement };
  
  amplitude = new Uniform.float(0.0);
  uniforms = { "amplitude" : amplitude };
  
  camera = new PerspectiveCamera(fov, window.innerWidth / window.innerHeight, 1.0, 10000.0);
  camera.position.z = 100.0;
  camera.lookAt(new Vector3(0.0, 0.0, 0.0));
  scene.add(camera);
  
  material = new ShaderMaterial(vertexShader: querySelector('#vertexShader').text, 
                                fragmentShader: querySelector('#fragmentShader').text,
                                attributes: attributes,
                                uniforms: uniforms);
  
  mesh = new Mesh(new IcosahedronGeometry(20.0, 4.0), material);
  var vertices = mesh.geometry.vertices;
  for( var v = 0; v < vertices.length; v++ ) 
  {
    displacement.value.add(rand.nextDouble() * 4.0 - 2.0);
  }
  
  scene.add(mesh);
  
  renderer = new WebGLRenderer();
  renderer.setSize(window.innerWidth, window.innerHeight);
  document.body.append(renderer.domElement);
}

double animator = 0.0;
void render(double frameTime)
{
  uniforms["amplitude"].value = sin(animator);
  animator += 0.03;
  renderer.render(scene, camera);
  window.animationFrame.then(render);
}
