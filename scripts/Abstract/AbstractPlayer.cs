using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class AbstractPlayer : MonoBehaviour
{
    public List<AbstractVehicle> vehicles;
    protected private AbstractVehicle currentVehicle;
    protected private int currentVehicleId = 0;
    
    void Start()
    {
        currentVehicle = vehicles[currentVehicleId];
        currentVehicle.turnOnOff(true);
        CameraController.CamController.SetTarget(currentVehicle.engine.gameObject);
    }

    
    void Update()
    {
        handleInput();
    }

    protected private abstract void handleInput();
}
