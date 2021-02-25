using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterWaveEffect : PostEffectsBase {

    public Shader waveShader;

    private Material waveMaterial;

    public Material material
    {
        get
        {
            waveMaterial = CheckShaderAndCreateMaterial(waveShader, waveMaterial);
            return waveMaterial;
        }
    }

    public float distanceFactor = 60.0f;

    public float timeFactor = -30.0f;

    public float totalFactor = 1.0f;

    public float waveWidth = 0.3f;
    public float waveSpeed = 0.3f;

    private float waveStartTime;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material!=null)
        {
            float curWaveDistance = (Time.time - waveStartTime) * waveSpeed;

            material.SetFloat("_distanceFactor", distanceFactor);
            material.SetFloat("_timeFactor", timeFactor);
            material.SetFloat("_totalFactor", totalFactor);
            material.SetFloat("_waveWidth", waveWidth);
            material.SetFloat("_curWaveDis", curWaveDistance);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    private void OnEnable()
    {
        //设置startTime
        waveStartTime = Time.time;
    }
}
