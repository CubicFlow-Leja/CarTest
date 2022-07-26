using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class AbstractVehicle : MonoBehaviour
{
    protected private bool On = false;
    public List<WheelClass> wheels;
    public Rigidbody engine;
    public Transform centerOfMass;

    public float torque = 1500f;
    public float steer = 45f;
    public float driftFriction = 2f;

    protected private InputClass input;
    void Start()
    {
        engine.centerOfMass = centerOfMass.transform.localPosition;
        foreach (WheelClass wheel in wheels)
            wheel.wheelCol.sprungMass = engine.mass * wheel.sprungMassFactor;
        input = new InputClass(Vector2.zero);
    }

    public void setInput(InputClass _input)
    {
        input = _input;
    }

    public abstract void turnOnOff(bool _on);
    protected private abstract void drive();
    void FixedUpdate()
    {
        drive();
    }
}
