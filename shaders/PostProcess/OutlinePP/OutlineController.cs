using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class OutlineController : MonoBehaviour
{
    public static OutlineController Controller { set; get; }
    
    private Camera cam;

    [Header("Shaders")]
    public Shader _outlineShader;
    public Shader Pastel;
   // public Shader _RayMarchShader;

    [Header("Materials")]
    private Material OutlineMat;
    private Material PastelMat;
   // private Material RayMarchMat;

    [Header("Outline")]
    public Color OutlineCol;
    public float _Scale;
    public int _Dist;

    [Header("WaterColor")]
    //public bool UsePixel;
    public int DownSample=9;
    //public int DownSampleDeathEffect=5;
    //private int DownSampleCurrent =9;
    [Range(0,1)]
    public float DownSampleStrength=0.4f;
   // public int Columns;
    [Range(1, 32)]
    public int _Iterations;



   // [Header("Clouds")]
   // //public bool UseRaymarch=false;
   // [Range(0,100)]
   // public int Step;
   // [Range(0, 50)]
   // public int MaxStepCointainer;
   // [Range(0.01f, 2)]
   // public float _FixedStepLength;
   // public float Intensity;
   // public float SampleThresh;
   // public float Alpha;
   // public float Atten;
   // public float Scale;
   // public float Scale2;
   // public float Speed1;
   // public float Speed2;
   // public float Sample1;
   // public float CloudScale=150;
   //// public float Athmosphere;
   // public Transform CloudAreaObj;



    public Material _OutlineMat
    {
        get
        {
            if (!OutlineMat && _outlineShader)
            {
                OutlineMat = new Material(_outlineShader);
                OutlineMat.hideFlags = HideFlags.HideAndDontSave;
            }

            return OutlineMat;
        }
    }
    public Material _PastelMat
    {
        get
        {
            if (!PastelMat && Pastel)
            {
                PastelMat = new Material(Pastel);
                PastelMat.hideFlags = HideFlags.HideAndDontSave;
            }

            return PastelMat;
        }
    }
    //public Material _RayMarchMat
    //{
    //    get
    //    {
    //        if (!RayMarchMat && _RayMarchShader)
    //        {
    //            RayMarchMat = new Material(_RayMarchShader);
    //            RayMarchMat.hideFlags = HideFlags.HideAndDontSave;
    //        }

    //        return RayMarchMat;
    //    }
    //}
    public Camera _camera
    {
        get
        {
            if (!cam)
            {
                cam = GetComponent<Camera>();
                cam.depthTextureMode = DepthTextureMode.Depth;
            }
            return cam;
        }
    }


    //[Header("Cloud Tex Generation")]
    //public int NumberOfDots;
    //public ComputeShader CloudCompute;
    //public float CloudPointRadius;
    //public int CloudRes=256;
    ////private RenderTexture HeightMap;

    ////private RenderTexture RND;

    ////private float RadRoll;
    ////private float HeightRoll;
    ////private int Harmonics;
    //public RenderTexture Cloud3DMap;

    private void Start()
    {
        if (Controller == null)
            Controller = this;
        else
            Destroy(this.gameObject);

       // Generate3DCloudMap();
    }

    public float DeathDuration = 0.5f;
    //private float DeathFloat = 0;
    //private float time = 0;
    //private bool DeathEffectActive = false;
    //public void DeathOccured()
    //{
    //    if(!DeathEffectActive)
    //    {
    //        DeathEffectActive = true;
    //        StartCoroutine(DeathEffect());
    //    }
    //    else
    //    {
    //        time = Time.realtimeSinceStartup;
    //        DeathFloat = time;
    //    }
    //}

    //private float TimeScale = 0;
    //public void Update()
    //{
    //    if(DeathEffectActive)
    //    {
    //        //DownSampleCurrent+= (DownSampleDeathEffect - DownSampleCurrent) * Time.unscaledDeltaTime;
    //        DownSampleCurrent = DownSampleDeathEffect;
    //        TimeScale += (0f-TimeScale)*Time.unscaledDeltaTime*10f;
    //        Time.timeScale = TimeScale;
    //    }
    //    else
    //    {
    //        //DownSampleCurrent += (DownSample - DownSampleCurrent) * Time.unscaledDeltaTime;
    //       // DownSampleCurrent = DownSample;
    //        TimeScale += (1f - TimeScale) * Time.unscaledDeltaTime*2f;
    //        Time.timeScale = TimeScale;
    //        if(TimeScale>0.75f)
    //            DownSampleCurrent = DownSample;
    //    }
        
    //}
    //private IEnumerator DeathEffect()
    //{
    //    time = Time.realtimeSinceStartup;
    //    DeathFloat = time;
    //   // DownSampleCurrent = DownSampleDeathEffect;
    //    while (DeathFloat - time < DeathDuration)
    //    {
    //        DeathFloat= Time.realtimeSinceStartup;
    //        yield return new WaitForSecondsRealtime(Time.deltaTime);
    //    }
    //   // DownSampleCurrent = DownSample;
    //    DeathEffectActive = false;
    //    DeathFloat = 0;
    //    yield return null;
    //}

    //private void Generate3DCloudMap()
    //{
    //    //za oblak bomba
    //    List<Vector4> Dots = new List<Vector4>();
    //  //  float h = 1f;
    //    float Rad = CloudPointRadius;
    //    //for (int H = 0; H < Harmonics; H++)
    //    //{
    //        for (int i = 0; i < NumberOfDots; i++)
    //        {
    //            Vector4 temp = Vector4.zero;

    //            float rad = Rad;
    //            //float rad = Random.Range(Rad * 0.9f, Rad);
    //           // float Height = Random.Range(h * 0.9f, h);

    //            temp.x = Random.Range(0.0f, 1f);
    //            temp.y = Random.Range(0.0f, 1f);
    //            temp.z = Random.Range(0.0f, 1f);
    //            temp.w = rad;
    //            Dots.Add(temp);

    //            for (int c = -1; c < 2; c++)
    //                for (int a = -1; a < 2; a++)
    //                    for (int b = -1; b < 2; b++)
    //                    {
    //                        if (a == 0 && b == 0 && c == 0)
    //                            continue;

    //                        Vector4 temp2 = temp;
    //                        temp2.x += a;
    //                        temp2.z += b;
    //                        temp2.y += c;
    //                        Dots.Add(temp2);
    //                    }
    //    }
    //    //h = Mathf.Lerp(h, 0, HeightRollOff);
    //    //// Rad /= RadRolOff;
    //    //Rad = Mathf.Lerp(Rad, 0, HeightRollOff);
    //    // }

    //    //Create i flash
    //    Cloud3DMap = new RenderTexture(CloudRes, CloudRes, 0);
    //    Cloud3DMap.format = RenderTextureFormat.RFloat;
    //    Cloud3DMap.enableRandomWrite = true;
    //    Cloud3DMap.dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
    //    Cloud3DMap.volumeDepth = CloudRes;
    //    Cloud3DMap.wrapMode = TextureWrapMode.Repeat;
    //    Cloud3DMap.Create();

    //    int F = CloudCompute.FindKernel("Flash");
    //    CloudCompute.SetTexture(F, "CloudMap", Cloud3DMap);
    //    CloudCompute.Dispatch(F, Cloud3DMap.width / 8, Cloud3DMap.height / 8, Cloud3DMap.height/8);




    //    int k = CloudCompute.FindKernel("GenerateCloud");
    //    CloudCompute.SetTexture(k, "CloudMap", Cloud3DMap);
    //    CloudCompute.SetVectorArray("Dots", Dots.ToArray());
    //    CloudCompute.SetInt("NumberOfDots", Dots.Count);
    //    //Compute.SetFloat("Persistance", Persistance);
    //    //Compute.SetFloat("Roughness", Roughness);
    //    //Compute.SetInt("Harmonics", Harmonics);
    //    //Compute.SetFloat("_Period", _Period);
    //    CloudCompute.SetFloat("TexSize", Cloud3DMap.width);
    //    //Compute.SetFloat("Radius", Radius);

    //    CloudCompute.Dispatch(k, Cloud3DMap.width / 8, Cloud3DMap.height / 8, Cloud3DMap.height / 8);
    //}


    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //triba izvadit iz bilda da je samo na startup, ovo je suludi waste
        Debug.Log("ukloni iz bilda");
        _OutlineMat.SetColor("_OutlineColor", OutlineCol);
        _OutlineMat.SetFloat("_Scale", _Scale);
        _OutlineMat.SetFloat("_Dist", _Dist);

      //  _PastelMat.SetInt("_Columns", Columns);
        _PastelMat.SetInt("_DownSample", DownSample);
        _PastelMat.SetFloat("DownSampleStrength", DownSampleStrength);
        _PastelMat.SetInt("_Iterations", _Iterations);

        //_RayMarchMat.SetFloat("_AlphaFactor", Alpha);
        //_RayMarchMat.SetInt("_MaxFixedStep", Step);
        //_RayMarchMat.SetFloat("_FixedStepLength", _FixedStepLength);
        //_RayMarchMat.SetInt("_MaxStep", MaxStepCointainer);
        //_RayMarchMat.SetFloat("_SampleThreshold", SampleThresh);
        //_RayMarchMat.SetFloat("_Intensity", Intensity);
        //_RayMarchMat.SetFloat("_AttenFactor", Atten);
        //_RayMarchMat.SetFloat("_Scale", Scale);
        //_RayMarchMat.SetFloat("_Scale2", Scale2);
        //_RayMarchMat.SetFloat("_Speed1", Speed1);
        //_RayMarchMat.SetFloat("_Speed2", Speed2);
        //_RayMarchMat.SetFloat("_SampleFac1", Sample1);
        //_RayMarchMat.SetFloat("_CloudScale", CloudScale);
        //_RayMarchMat.SetMatrix("_CamFrustum", CamFrustum(_camera));
        //_RayMarchMat.SetMatrix("_CamToWorld", _camera.cameraToWorldMatrix);
        //_RayMarchMat.SetVector("BoxScale", CloudAreaObj.transform.localScale);
        //_RayMarchMat.SetVector("BoxPosition", CloudAreaObj.transform.position);
        //_RayMarchMat.SetTexture("_Cloud3DMap", Cloud3DMap);

        RenderTexture TempTex1 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
        RenderTexture TempTex2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

        //outline
        Graphics.Blit(source, TempTex1, _OutlineMat);

        ////RAYMARCH
        //Graphics.Blit(TempTex1, TempTex2, _RayMarchMat);

        //PIXEL I DOWNSCALE
        // Graphics.Blit(TempTex1, destination, _PixelMat);

        //Graphics.Blit(TempTex1, TempTex2, _PixelMat);
        //Graphics.Blit(TempTex2, TempTex1, _PixelMat);
        //Graphics.Blit(TempTex1, TempTex2, _PixelMat);
        //Graphics.Blit(TempTex2, TempTex1, _PixelMat);
        //Graphics.Blit(TempTex1, TempTex2, _PixelMat);
        //Graphics.Blit(TempTex2, TempTex1, _PixelMat);
       // Graphics.Blit(TempTex1, TempTex2, _PixelMat);
        //Graphics.Blit(TempTex2, TempTex1, _PixelMat);
        //Graphics.Blit(TempTex1, TempTex2, _PixelMat);

        //Graphics.Blit(TempTex2, destination, _PixelMat);
        Graphics.Blit(TempTex1, destination, _PastelMat);

        RenderTexture.ReleaseTemporary(TempTex1);
      //  RenderTexture.ReleaseTemporary(TempTex2);
    }

    //private Matrix4x4 CamFrustum(Camera cam)
    //{
    //    Matrix4x4 frustum = Matrix4x4.identity;
    //    float fov = Mathf.Tan((cam.fieldOfView * 0.5f) * Mathf.Deg2Rad);
    //    Vector3 up = -Vector3.up * fov;
    //    Vector3 right = Vector3.right * fov * cam.aspect;
    //    Vector3 TL = (-Vector3.forward - right + up);
    //    Vector3 TR = (-Vector3.forward + right + up);
    //    Vector3 BL = (-Vector3.forward - right - up);
    //    Vector3 BR = (-Vector3.forward + right - up);

    //    frustum.SetRow(0, TL);
    //    frustum.SetRow(1, TR);
    //    frustum.SetRow(2, BR);
    //    frustum.SetRow(3, BL);
    //    return frustum;
    //}
}
