using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour
{
    [Range(0f, 1f)]
    public float turnsPerSecond = 0.25f;

    public void Update()
    {
        transform.Rotate(0, 360 * turnsPerSecond * Time.deltaTime, 0);
    }
}
