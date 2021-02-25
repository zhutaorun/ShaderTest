using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClickPosWaterWaveEffect : PostEffectsBase {

    public Shader shader;

    private Material waveMaterial;

    public Material material
    {
        get
        {
            waveMaterial = CheckShaderAndCreateMaterial(shader, waveMaterial);
            return waveMaterial;
        }
    }


    public float distanceFactor = 60.0f;
    public float timeFactor = -30.0f;
    public float totalFactor = 1.0f;
    public float waveWidth = 0.3f;
    public float waveSpeed = 0.3f;

    private float waveStartTime;
    private Vector4 startPos = new Vector4(0.5f, 0.5f, 0, 0);

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        
        if(material!=null)
        {
            //计算波纹移动的距离，根据enable到目前的时间*速度求解
            float curWaveDistance = (Time.time - waveStartTime) * waveSpeed;
            //设置一系列参数
            material.SetFloat("_distanceFactor", distanceFactor);
            material.SetFloat("_timeFactor", timeFactor);
            material.SetFloat("_totalFactor", totalFactor);
            material.SetFloat("_waveWidth", waveWidth);
            material.SetFloat("_curWaveDis", curWaveDistance);
            material.SetVector("_startPos", startPos);
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    private void Update()
    {
        if(Input.GetMouseButton(0))
        {
            Vector2 mousePos = Input.mousePosition;
            //将mousePos转化(0,1)区间
            startPos = new Vector4(mousePos.x / Screen.width, mousePos.y / Screen.height, 0, 0);
            waveStartTime = Time.time;
        }
    }
}
