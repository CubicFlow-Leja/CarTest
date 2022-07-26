using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class ShaderVariableController : MonoBehaviour
{
    public static ShaderVariableController Controller { set; get; }

    //private float _Time = 0.0f;
    public Color _ShadowColor;
    public Color _GlobalColor;
    //public GameObject Camera;
    //public GameObject CameraControllerObj;



    private void Awake()
    {
        Controller = this;
    }
    void Start()
    {
        Shader.SetGlobalColor("_ColorShadow", _ShadowColor);
        Shader.SetGlobalColor("_GlobalColor", _GlobalColor);
        //Shader.SetGlobalFloat("_TimeSinceStartUp", _Time);
        //Shader.SetGlobalVector("_ViewDir", new Vector4(Camera.transform.forward.x, Camera.transform.forward.y, Camera.transform.forward.z));

        //Cursor.lockState = CursorLockMode.Confined;
        //Debug.Log("cursor confined true");
    }

    void Update()
    {
        //_Time = Time.realtimeSinceStartup;
        Shader.SetGlobalColor("_ColorShadow", _ShadowColor);
        //Shader.SetGlobalFloat("_TimeSinceStartUp", _Time);
        Shader.SetGlobalColor("_GlobalColor", _GlobalColor);
    }

}
