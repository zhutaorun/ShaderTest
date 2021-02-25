using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RadialBlurEffect1 : PostEffectsBase {
    public Shader blurShader;

    private Material blurMaterial;

    public Material material
    {
        get {
            blurMaterial = CheckShaderAndCreateMaterial(blurShader, blurMaterial);
            return blurMaterial;
        }
    }

    //模糊程度,不能过高
    [Range(0, 0.05f)]
    public float blurFactor = 1.0f;
    //模糊中心(0-1)屏幕空间，默认为中心点
    public Vector2 blurCenter = new Vector2(0.5f, 0.5f);

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material!=null)
        {
            material.SetFloat("_BlurFactor", blurFactor);
            material.SetVector("_BlurCenter", blurCenter);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

}
