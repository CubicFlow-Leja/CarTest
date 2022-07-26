using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GrassRenderer : MonoBehaviour
{
    public int Seed;

  
    private MeshFilter Filter;
    private MeshRenderer Rend;
    private Mesh _Mesh;

    [Range(0, 24000)]
    public int Quantity;

    public float SizeX;
    public float SizeZ;

    public LayerMask Mask;

    public float RayHeight;
    public float Offset;


    public bool Reset = false;
    
    void Update()
    {

        if (Reset)
        {
            Filter = this.GetComponent<MeshFilter>();

            Random.InitState(Seed);
            List<Vector3> Positions = new List<Vector3>(Quantity);
            List<Vector3> Normals = new List<Vector3>(Quantity);
            List<Vector2> Uvs = new List<Vector2>(Quantity);
            List<int> indices = new List<int>(Quantity);
            List<Color> Colors = new List<Color>(Quantity);

            int a = 0;
            for (int i = 0; i < Quantity; i++)
            {
                Vector3 CastLocation = transform.position;
                Vector3 Temp = Vector3.zero;
                CastLocation.y += RayHeight;

                Temp.x = Random.Range(-0.5f, 0.5f);
                Temp.z = Random.Range(-0.5f, 0.5f);

                //while (true)
                //{
                //    Temp.x = Random.Range(-0.5f, 0.5f);
                //    Temp.z = Random.Range(-0.5f, 0.5f);


                //    if (Temp.magnitude <= 0.5f)
                //    {
                //        //if (Temp.magnitude >= 0.25f)
                //        //{
                //           // float x = Random.Range(Temp.magnitude, 1);
                //            if (Random.Range(Temp.magnitude, 1) < 0.55f)
                //                break;
                //        //}
                //        //else
                //        //    break;
                //    }
                //        //Temp = Temp.normalized * 0.5f;
                       
                //}
              

                CastLocation.x += SizeX * Temp.x;
                CastLocation.z += SizeZ * Temp.z;
                //CastLocation.x += SizeX * Random.Range(-0.5f, 0.5f);
                //CastLocation.z += SizeZ * Random.Range(-0.5f, 0.5f);

                Ray ray = new Ray(CastLocation, Vector3.down);
                RaycastHit hit;


                if (Physics.Raycast(ray, out hit))
                {

                    if (Mask == (Mask | (1 << hit.transform.gameObject.layer)))
                    {
                        CastLocation = hit.point - transform.position + Vector3.up * Offset;
                        Positions.Add(CastLocation);
                        Normals.Add(hit.normal);
                        indices.Add(a++);
                        Uvs.Add(new Vector2(((hit.point - transform.position).x + SizeX * 0.5f) / SizeX, ((hit.point - transform.position).z + SizeZ * 0.5f) / SizeZ));
                        Colors.Add(new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), 1.0f));
                    }
                }
                _Mesh = new Mesh();
                _Mesh.SetVertices(Positions);
                _Mesh.SetIndices(indices, MeshTopology.Points, 0);
                _Mesh.SetColors(Colors);
                _Mesh.SetNormals(Normals);
                _Mesh.SetUVs(0, Uvs);
                _Mesh.name = "Oblak";
                Filter.sharedMesh = _Mesh;
                _Mesh.RecalculateBounds();

                

            }
            Reset = false;
        }


        //this.GetComponent<GrassRenderer>().enabled = false;



    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireCube(transform.position, new Vector3(SizeX/2, 1, SizeZ/2));
    }
}
