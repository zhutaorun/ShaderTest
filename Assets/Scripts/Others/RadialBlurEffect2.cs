using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RadialBlurEffect2 : PostEffectsBase {
    public Shader blurShader;
    private Material blurMaterial;

    public Material material
    {
        get
        {
            blurMaterial = CheckShaderAndCreateMaterial(blurShader, blurMaterial);
            return blurMaterial;
        }
    }

    [Range(0, 0.1f)]
    public float blurFactor = 1.0f;
    //清晰图像与原图插值
    [Range(0.0f, 2.0f)]
    public float lerpFactor = 0.5f;
    //降低分辨率
    public int downSampleFactor = 2;
    //模糊中心(0-1)屏幕空间,默认为中心点
    public Vector2 blurCenter = new Vector2(0.5f, 0.5f);

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material!=null)
        {
            //申请两块降低了分辨率的RT
            RenderTexture rt1 = RenderTexture.GetTemporary(src.width >> downSampleFactor, src.height >> downSampleFactor,0,src.format);
            RenderTexture rt2 = RenderTexture.GetTemporary(src.width >> downSampleFactor, src.height >> downSampleFactor, 0, src.format);

            Graphics.Blit(src, rt1);

            //使用降低分辨率的rt进行模糊:pass0
            material.SetFloat("_BlurFactor", blurFactor);
            material.SetVector("_BlurCenter", blurCenter);
            Graphics.Blit(rt1, rt2, material, 0);

            //使用rt2和原始图像lerp:pass1
            material.SetTexture("_BlurTex", rt2);
            material.SetFloat("_LerpFactor", lerpFactor);
            Graphics.Blit(src, dest, material, 1);

            //释放RT
            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

}
