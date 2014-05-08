import 'dart:html';
import 'dart:math';
import 'package:three/three.dart';
import 'package:vector_math/vector_math.dart';

Scene scene;
PerspectiveCamera camera;
WebGLRenderer renderer;

Map<Mesh, Vector3> cubeOffsets = new Map<Mesh, Vector3>(); 
List<Mesh> cubes = new List<Mesh>();
PointLight pointLight;

var displacement, attributes;

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

  displacement = new Attribute.float();
  attributes = { "displacement" : displacement };
  
  var vShader = querySelector("#vertexshader");
  var fShader = querySelector("#fragmentshader");
  var shaderMaterial = new ShaderMaterial(vertexShader:   vShader.text, 
                                          fragmentShader: fShader.text,
                                          attributes:     attributes);
  
  var basePosition = new Vector3(1.0, 1.0, 1.0);
  var geometry = new CubeGeometry(basePosition.x, basePosition.y, basePosition.z);
  Random rand = new Random();
  //for (int i = 0; i < 5; i++)
  {
    var cube = new Mesh(geometry, shaderMaterial);
    var offset = new Vector3(rand.nextDouble() * 5.0 - 2.5, rand.nextDouble() * 5.0 - 2.5, 0.0);
    cube.position += offset;
    var vertices = cube.geometry.vertices;
    for( var v = 0; v < vertices.length; v++ ) 
    {
      displacement.value.add(rand.nextDouble() * 4.0 - 2.0);
    }
    scene.add(cube);
    cubes.add(cube);
    cubeOffsets[cube] = offset;
  }
  
  camera.position.z = 5.0;
}

void render(double frameTime)
{
  cubes.forEach((cube) => animate(cube));
  renderer.render(scene, camera);
  window.animationFrame.then(render);
}

void animate(Mesh mesh)
{
  mesh.rotation.x += 0.05;
  mesh.rotation.y += 0.05;
}

void move(Mesh mesh, Vector3 pos, Vector3 offset)
{
  mesh.position.x = pos.x + offset.x;
  mesh.position.y = pos.y + offset.y;
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
  cubes.forEach((cube) => move(cube, pos, cubeOffsets[cube]));
}
