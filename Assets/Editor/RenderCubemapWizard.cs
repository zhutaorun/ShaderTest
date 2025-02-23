﻿using System.Collections;
using UnityEditor;
using UnityEngine;

public class RenderCubemapWizard : ScriptableWizard
{

    public Transform renderFromPosition;
    public Cubemap cubemap;
	void OnWizardUpdate () {
        helpString = "Select transform to render from and cubemap to render into";
        isValid = (renderFromPosition != null) && (cubemap!=null);
	}
	
	// Update is called once per frame
	void OnWizardCreate () {
        //create temporary camera for rendering
        GameObject go = new GameObject("CubemapCamera");
        go.AddComponent<Camera>();

        //place it on the object
        go.transform.position = renderFromPosition.position;
        //render into cubemap
        go.GetComponent<Camera>().RenderToCubemap(cubemap);

        //dstroy temporary camera
        DestroyImmediate(go);
	}

    [MenuItem("GameObject/Render into Cubemap")]
    static void RenderCubemap()
    {
        ScriptableWizard.DisplayWizard<RenderCubemapWizard>(
            "Render cubemap","Render!");
    }

}
