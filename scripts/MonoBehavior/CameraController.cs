using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class CameraController : MonoBehaviour
{
    public static CameraController CamController { set; get; }

    public Camera _Camera;
    private GameObject _Target;
    private Vector3 MoveVectorTarget;
    private Vector3 MoveVectorCurr;


    public float Height = 3;

    public float Speed;
    public float SpeedGrav=1f;
    public float RotateSpeed;
    public float RotateSpeedGrav=1.0f;
    private float RotateSpeedCurr;
    private float RotateSpeedTarget;

    //kontroliran TargetFogVal
    public float FogDefaultVal = 0.5f;
    public bool MainMenu = false;
    public void SetTarget(GameObject obj)
    {
        _Target = obj;
    }
    private void Awake()
    {
        if (CamController == null)
            CamController = this;
    }
    void Start()
    {
        if (MainMenu)
            return;
      
        MoveVectorTarget = Vector3.zero;
        MoveVectorCurr = Vector3.zero;
    }

    public void SetCameraStart(Quaternion quat,Vector3 pos)
    {
        this.transform.position = pos;
        this.transform.rotation = quat;
    }
   
    void FixedUpdate()
    {
        if (_Target == null)
            return;
        
        MoveAndRotate();
    }



    

    private void MoveAndRotate()
    {
       // if(Input.GetKey(KeyCode.Mouse2))
            RotateSpeedCurr += (RotateSpeedTarget - RotateSpeedCurr) * Time.deltaTime * RotateSpeedGrav;
        //else
        //    RotateSpeedCurr += (0 - RotateSpeedCurr) * Time.deltaTime * RotateSpeedGrav;

        this.transform.RotateAround(this.transform.position, this.transform.up, RotateSpeedCurr * Time.deltaTime * RotateSpeed);
        
        MoveVectorTarget.y = Height + _Target.transform.position.y - this.transform.position.y;
        MoveVectorTarget.x = _Target.transform.position.x - this.transform.position.x;
        MoveVectorTarget.z = _Target.transform.position.z - this.transform.position.z;

        MoveVectorCurr += (MoveVectorTarget - MoveVectorCurr) * Time.deltaTime * SpeedGrav;
        
        this.transform.Translate(MoveVectorCurr * Time.deltaTime * Speed, Space.World);
    }



    public void Rotate(float RotateFac)
    {
        //axis mi je invertiran kek 
       // RotateSpeedTarget =-RotateFac;
        RotateSpeedTarget =RotateFac;
    }
}
