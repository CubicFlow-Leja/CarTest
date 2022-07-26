using UnityEngine;

[System.Serializable]
public class WheelClass
{
    public WheelCollider wheelCol;
    public Transform wheel;
    public bool drive;
    public bool steer;
    [Range(0, 1f)]
    public float sprungMassFactor;
    public WheelClass(WheelCollider _wheelCol, bool _drive, bool _steer, Transform _wheel, float _sprungMassFactor)
    {
        this.wheelCol = _wheelCol;
        this.wheel = _wheel;
        this.drive = _drive;
        this.steer = _steer;
        this.sprungMassFactor = _sprungMassFactor;
    }
}

