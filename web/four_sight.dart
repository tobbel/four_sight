import 'dart:html';
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';

Scene scene;
PerspectiveCamera camera;
WebGLRenderer renderer;

Mesh cube;
PointLight pointLight;

void main()
{
  init();

  window.animationFrame.then(render);
}

void init()
{
  scene = new Scene();
  camera = new PerspectiveCamera(75.0, window.innerWidth / window.innerHeight, 0.1, 1000.0);
  renderer = new WebGLRenderer();
  
  renderer.setSize(window.innerWidth, window.innerHeight);
  document.body.append(renderer.domElement);

  renderer.domElement.onMouseMove.listen(mouseMove);
  
  var vShader = querySelector("#vertexshader");
  var fShader = querySelector("#fragmentshader");
  var shaderMaterial = new ShaderMaterial(vertexShader:vShader.text, 
                                          fragmentShader:fShader.text);
  
  
  var geometry = new CubeGeometry(1.0, 1.0, 1.0);
  //var material = new MeshBasicMaterial(color: 0x00ff00);
  var material = new MeshLambertMaterial(color: 0xcc0000);
  cube = new Mesh(geometry, shaderMaterial);
  
  scene.add(cube);
  
  camera.position.z = 5.0;
}

void render(double frameTime)
{
  cube.rotation.x += 0.05;
  cube.rotation.y += 0.05;
  renderer.render(scene, camera);
  window.animationFrame.then(render);
}


void mouseMove(MouseEvent e)
{
  var vector = new Vector3(
      ( e.client.x / window.innerWidth ) * 2 - 1,
      - ( e.client.y / window.innerHeight ) * 2 + 1,
      1.0 );
  Projector projector = new Projector();
  projector.unprojectVector( vector, camera );

  var dir = vector.sub( camera.position ).normalize();

  var distance = - camera.position.z / dir.z;
  
  var pos = camera.position.clone().add( dir * distance );
  cube.position.x = pos.x;
  cube.position.y = pos.y;
}
