using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
//[ExecuteInEditMode] 
public class GrassNormalMapCalculator : MonoBehaviour
{
   //triba bit static tako da svi referencaju njemu water targete
    [Header("Materials and shaders")]
    public ComputeShader Compute;
    public Shader GrassShader;
    public Shader GrassShaderNoShadows;
    
    public Texture2D GrassShaderTexture;
    public Texture2D GrassHeightTexture;
    private Material simulatedmaterial;


    [Header("Grow")]
    public GameObject GrowObj;
    public float MaxGrowRadius;
    private float CurrentGrowthRad = 0;
    [Range(0, 1)]
    public float GrowTime = 0.25f;
 
    [Header("Params")]
    public float GrassPlaneSize;
    public float CalcHeight;
    private Vector3 GrassPlaneCenter;


    [Range(0, 80)]
    public float Radius;
    [Range(0, 100)]
    public float DeformationSpeed;
    [Range(0, 25)]
    public float FixSpeed;
    [Range(0, 3)]
    public float GrassHeight;
    [Range(0, 3)]
    public float GrassWidth;
    [Range(0, 1)]
    public float GrassCutoff;

    [Range(0, 25)]
    public float WateringSpeed;
    [Range(0, 1)]
    public float DrySpeed;
    [Range(0, 200)]
    public float WateringRadius;

    public Color GrassColor;
    public Color GrassColorDry;

    [Range(0, 1)]
    public float _WindFac = 0.1f;
    [Range(0, 4)]
    public float _WindSpeed = 0.1f;
    [Range(0.1f, 100)]
    public float _WindPosParam =5f;

  


    [Header("Detection and objects")]
    public List<GameObject> Objects = new List<GameObject>();
    public List<Transform> WaterObjects = new List<Transform>();
    public LayerMask CanDeform;
    public LayerMask PhysicsDetMask;

    [Header("Renderer and Textures")]
    public GameObject GrassRend;
    public Texture2D InitialInput;

    private RenderTexture RenderTex;
    private RenderTexture DeformationTex;

    private RenderTexture WetMap;
    private RenderTexture WetMapTemp;


    [Header("Reinit")]
    public bool reinitialize=true;

    //helpers
    private int A;
    private int PhysicsSimId;
    private int WetId;
    
    void Start()
    {
        Init();
    }
    
  
    void Update()
    {
        if (reinitialize)
        {
            reinitialize = false;
            Init();
        }
      
        GrowDecay();
       
    }


    private void GrowDecay()
    {
        if (Objects.Count != 0)
        {
            CurrentGrowthRad += (MaxGrowRadius - CurrentGrowthRad) * Time.deltaTime * GrowTime;
            Dispatch();
        }
        else
            CurrentGrowthRad += (0 - CurrentGrowthRad) * Time.deltaTime * GrowTime;
        SetParams();
    }



    private void Dispatch()
    {
       // SetParams();
        CreatePosList();
        CreateWetList();
      
        Compute.Dispatch(WetId, RenderTex.width / 8, RenderTex.height / 8, 1);
        Compute.Dispatch(PhysicsSimId, RenderTex.width / 8, RenderTex.height / 8, 1);
    }

    #region Lists
    private void CreatePosList()
    {
        A = 0;
        List<Vector4> Temp = new List<Vector4>();
        List<Vector4> TempFW = new List<Vector4>();

        for (int i = 0; i < Objects.Count; i++)
        {
            RaycastHit hit;
            //if (Objects[i].activeSelf && Objects[i].transform.position.y-GrassPlaneCenter.y-CalcHeight<=0)
            if (Objects[i].activeSelf && Objects[i].GetComponent<Renderer>().isVisible && Physics.Raycast(Objects[i].transform.position+Vector3.up* CalcHeight, Vector3.down,out hit,2*CalcHeight, PhysicsDetMask))
            {
                //Vector4 TempVec = new Vector4((Objects[i].transform.position.x - GrassPlaneCenter.x + GrassPlaneSize * 0.5f) / GrassPlaneSize, (Objects[i].transform.position.y - GrassPlaneCenter.y )/ GrassPlaneSize , (Objects[i].transform.position.z - GrassPlaneCenter.z + GrassPlaneSize * 0.5f) / GrassPlaneSize);
                Vector4 TempVec = new Vector4((Objects[i].transform.position.x - GrassPlaneCenter.x + GrassPlaneSize * 0.5f) / GrassPlaneSize, (Objects[i].transform.position.y - hit.point.y)/CalcHeight  , (Objects[i].transform.position.z - GrassPlaneCenter.z + GrassPlaneSize * 0.5f) / GrassPlaneSize);
               // Vector4 TempVec = new Vector4((Objects[i].transform.position.x - GrassPlaneCenter.x + GrassPlaneSize * 0.5f) / GrassPlaneSize, (Objects[i].transform.position.y - hit.point.y)/CalcHeight  , (Objects[i].transform.position.z - GrassPlaneCenter.z + GrassPlaneSize * 0.5f) / GrassPlaneSize);
                Temp.Add(TempVec);
                Vector4 TempVec2 = new Vector4(Objects[i].GetComponentInParent<Rigidbody>().velocity.x , 0, Objects[i].GetComponentInParent<Rigidbody>().velocity.z);
                //Vector4 TempVec2 = new Vector4(Objects[i].transform.forward.x , Objects[i].transform.forward.y, Objects[i].transform.forward.z);
                TempFW.Add(TempVec2);
                // Debug.Log(Objects[i].transform.forward);
                //Debug.Log(TempVec);
                A++;
            }
            if (A == 15)
                break;
        }

        Compute.SetVectorArray("Positions", Temp.ToArray());
        Compute.SetInt("PositionsCount", Temp.ToArray().Length);
        Compute.SetVectorArray("PositionsFW", TempFW.ToArray());
        //Compute.SetInt("PositionsCountFW", TempFW.ToArray().Length);

    }
    

    private void CreateWetList()
    {
        List<Vector4> Templist = new List<Vector4>();

        foreach (Transform tr in WaterObjects)
        {
            //Vector4 TempVec = new Vector4((Objects[i].transform.position.x - GrassPlaneCenter.x + GrassPlaneSize * 0.5f) / GrassPlaneSize, (Objects[i].transform.position.y - hit.point.y) / CalcHeight, (Objects[i].transform.position.z - GrassPlaneCenter.z + GrassPlaneSize * 0.5f) / GrassPlaneSize);

            //Vector4 WaterLocation = new Vector4(WaterObjTest.position.x, WaterObjTest.localScale.x, WaterObjTest.position.z);
            Vector4 WaterLocation = new Vector4(((tr.position.x - GrassPlaneCenter.x + GrassPlaneSize * 0.5f)/ GrassPlaneSize),
                                                       tr.localScale.x,
                                                      ((tr.position.z - GrassPlaneCenter.z  + GrassPlaneSize * 0.5f)) / GrassPlaneSize);

            Templist.Add(WaterLocation);
        }

        Compute.SetInt("WaterLocationCount", Templist.Count);
        Compute.SetVectorArray("WaterLocations", Templist.ToArray());
    }

    #endregion




    #region ParamsNInit
    private bool Shadows = true;
    private void SetParams()
    {
        //if (SaveClass.GetSettings().GrassShadows != Shadows)
        //{
        //    Shadows = (Shadows) ? false : true;
        //    Shader TempShader = (Shadows) ? GrassShader : GrassShaderNoShadows;
        //    simulatedmaterial = new Material(TempShader);
        //    GrassRend.GetComponent<MeshRenderer>().material = simulatedmaterial;
        //    simulatedmaterial.SetTexture("_NoiseTex", RenderTex);
        //}



        simulatedmaterial.SetTexture("_MainTex", GrassShaderTexture);
        simulatedmaterial.SetTexture("_HeightChangeTex", GrassHeightTexture);
        simulatedmaterial.SetTexture("_WetMap", WetMap);

        simulatedmaterial.SetFloat("_Height", GrassHeight);
        simulatedmaterial.SetFloat("_Width", GrassWidth);
        simulatedmaterial.SetFloat("_CuttOff", GrassCutoff);
        simulatedmaterial.SetFloat("_WindSpeed", _WindSpeed);
        simulatedmaterial.SetFloat("_WindFac", _WindFac);
        simulatedmaterial.SetFloat("_WindPosParam", _WindPosParam);
        simulatedmaterial.SetColor("_Color", GrassColor);
        simulatedmaterial.SetColor("_ColorDry", GrassColorDry);


        //za growthsphere, moglo bi se optimizirat da nie ode svaki frame.
        simulatedmaterial.SetVector("GrowthCenter", new Vector4(GrowObj.transform.position.x, GrowObj.transform.position.y, GrowObj.transform.position.z));
        simulatedmaterial.SetFloat("GrowthRad", CurrentGrowthRad);
        //foreach (Material mat in TreeMats)
        //{
        //    mat.SetVector("GrowthCenter", new Vector4(GrowObj.transform.position.x, GrowObj.transform.position.y, GrowObj.transform.position.z));
        //    mat.SetFloat("GrowthRad", CurrentGrowthRad);
        //}

        Compute.SetFloat("MaxRad", Radius);
        Compute.SetFloat("DeformationSpeed", DeformationSpeed);
        Compute.SetFloat("FixSpeed", FixSpeed);
        Compute.SetFloat("WaterRadius", WateringRadius);
        Compute.SetFloat("WateringSpeed", WateringSpeed);
        Compute.SetFloat("DrySpeed", DrySpeed);
        Compute.SetFloat("TimeDelta", Time.deltaTime);
    
        
    }


  

    public void Init()
    {
        GrassPlaneCenter = this.transform.position;
        //foreach (Renderer rend in TreeRenderers)
        //{
        //    Material treemat = new Material(TreeMaterial);
        //    rend.sharedMaterial = treemat;
        //    TreeMats.Add(treemat);
        //}

        simulatedmaterial = new Material(GrassShader);


        GrassRend.GetComponent<MeshRenderer>().material = simulatedmaterial;

        Compute = (ComputeShader)Instantiate(Resources.Load("GrassNormalMapComputer"));


        //init compute
        PhysicsSimId = Compute.FindKernel("GrassPhysicsUpdate");
        WetId = Compute.FindKernel("WetCalculus");
        int overwrite = Compute.FindKernel("FlashInput");

        //init RNDTX
        RenderTex = new RenderTexture(InitialInput.width, InitialInput.height, 24);
        RenderTex.enableRandomWrite = true;
        RenderTex.Create();


        //RenderTexTemp = new RenderTexture(InitialInput.width, InitialInput.height, 24);
        //RenderTexTemp.enableRandomWrite = true;
        //RenderTexTemp.Create();


        DeformationTex = new RenderTexture(InitialInput.width, InitialInput.height, 24);
        DeformationTex.enableRandomWrite = true;
        DeformationTex.Create();

        WetMap = new RenderTexture(InitialInput.width, InitialInput.height, 24);
        WetMap.format = RenderTextureFormat.RFloat;
        WetMap.enableRandomWrite = true;
        WetMap.Create();

        WetMapTemp = new RenderTexture(InitialInput.width, InitialInput.height, 24);
        WetMapTemp.format = RenderTextureFormat.RFloat;
        WetMapTemp.enableRandomWrite = true;
        WetMapTemp.Create();

       
        //setanje u compute shaderu
        Compute.SetFloat("TexWidth", RenderTex.width);


        Compute.SetTexture(overwrite, "Input", InitialInput);
        Compute.SetTexture(overwrite, "Result", RenderTex);
        Compute.SetTexture(overwrite, "DeformationTemp", DeformationTex);
        Compute.SetTexture(overwrite, "WetMap", WetMap);
        Compute.SetTexture(overwrite, "WetMapTemp", WetMapTemp);
       // Compute.SetTexture(overwrite, "ResultTemp", RenderTexTemp);


        //proccan compute shader sa 8*8*1 thread 
        Compute.Dispatch(overwrite, RenderTex.width / 8, RenderTex.height / 8, 1);


        //result
        Compute.SetTexture(PhysicsSimId, "Result", RenderTex);
        Compute.SetTexture(PhysicsSimId, "DeformationTemp", DeformationTex);
        Compute.SetTexture(PhysicsSimId, "WetMap", WetMap);
        Compute.SetTexture(PhysicsSimId, "WetMapTemp", WetMapTemp);
          
        //WetCalc
        Compute.SetTexture(WetId, "Result", RenderTex);
        Compute.SetTexture(WetId, "DeformationTemp", DeformationTex);
        Compute.SetTexture(WetId, "WetMap", WetMap);
        Compute.SetTexture(WetId, "WetMapTemp", WetMapTemp);


        //Compute.SetTexture(PhysicsSimId, "ResultTemp", RenderTexTemp);

        //setat tex na material
        simulatedmaterial.SetTexture("_NoiseTex", RenderTex);

        SetParams();
    }

    #endregion

  

    public void OnTriggerEnter(Collider other)
    {
        if (CanDeform == (CanDeform | (1 << other.gameObject.layer)))
        {
            if (!Objects.Contains(other.gameObject))
            {
               
                Objects.Add(other.gameObject);
              


            }
        }
    }

    public void OnTriggerExit(Collider other)
    {
        if (CanDeform == (CanDeform | (1 << other.gameObject.layer)))
        {
            if (Objects.Contains(other.gameObject))
            {
                Objects.Remove(other.gameObject);
                
              
            }
        }
    }


    private void OnDrawGizmos()
    {
        //Gizmos.DrawLine(GrassPlaneCenter + CalcHeight * Vector3.up, GrassPlaneCenter);
    }
}
