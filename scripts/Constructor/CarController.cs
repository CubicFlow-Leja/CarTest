using UnityEngine;

public class CarController : AbstractVehicle
{
    public ParticleSystem exhaustSystem;
    public override void turnOnOff(bool _on)
    {
        if (_on)
            exhaustSystem.Play();
        else
            exhaustSystem.Stop();
    }

    protected private override void drive()
    {
        foreach (WheelClass wheel in wheels)
        {
            Quaternion wheelRot; Vector3 wheelPos;

            //steer
            if (wheel.steer)
                wheel.wheelCol.steerAngle = input.inputVector.x * steer;

            //wheel model alignment
            wheel.wheelCol.GetWorldPose(out wheelPos, out wheelRot);
            wheel.wheel.transform.position = wheelPos;
            wheel.wheel.transform.rotation = wheelRot;

            //motor
            if (wheel.drive)
            {
                wheel.wheelCol.motorTorque = input.inputVector.y * torque;

                //drift
                if (Input.GetKey(KeyCode.Space))
                {
                    WheelFrictionCurve curve = wheel.wheelCol.sidewaysFriction;
                    curve.extremumSlip = driftFriction;
                    wheel.wheelCol.sidewaysFriction = curve;
                }
                else
                {
                    WheelFrictionCurve curve = wheel.wheelCol.sidewaysFriction;
                    curve.extremumSlip = 0.15f;
                    wheel.wheelCol.sidewaysFriction = curve;
                }

            }
        }
    }
}
