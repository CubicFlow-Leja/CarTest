using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : AbstractPlayer
{

    private protected override void handleInput()
    {

        if (Input.GetKeyDown(KeyCode.Tab))
        {
            currentVehicleId = (currentVehicleId + 1) % vehicles.Count;
            currentVehicle.setInput(new InputClass(Vector2.zero));
            currentVehicle.turnOnOff(false);
            currentVehicle = vehicles[currentVehicleId];
            CameraController.CamController.SetTarget(currentVehicle.engine.gameObject);
            currentVehicle.turnOnOff(true);
        }
        Vector2 input = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxisRaw("Vertical"));
        currentVehicle.setInput(new InputClass(input));

        Debug.DrawLine(this.transform.position, this.transform.position + this.transform.right * input.x,Color.blue,0.1f);
        Debug.DrawLine(this.transform.position, this.transform.position + this.transform.forward * input.y,Color.green,0.1f);
    }

}
