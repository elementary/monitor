namespace NVCtrlLib {
   [CCode (cheader_filename = "NVCtrl/NVCtrlLib.h", cname = "XNVCTRLQueryAttribute", cprefix = "nv_ctrl_lib_", has_type_id = false)]
   public static bool XNVCTRLQueryAttribute (
      X.Display *dpy,
      int screen,
      uint display_mask,
      uint attribute,
      int *value
   );

   [CCode (cheader_filename = "NVCtrl/NVCtrlLib.h", cname = "XNVCTRLQueryTargetAttribute", cprefix = "nv_ctrl_lib_", has_type_id = false)]
   public static bool XNVCTRLQueryTargetAttribute (
      X.Display *dpy,
      int target_Type,
      int target_id,
      uint display_mask,
      uint attribute,
      int *value
   );

   [CCode (cheader_filename = "NVCtrl/NVCtrlLib.h", cname = "XNVCTRLQueryTargetStringAttribute", cprefix = "nv_ctrl_lib_", has_type_id = false)]
   public static bool XNVCTRLQueryTargetStringAttribute (
      X.Display *dpy,
      int target_type,
      int target_id,
      uint display_mask,
      uint attribute,
      char **ptr
   );

}

[CCode (cheader_filename = "NVCtrl/NVCtrl.h")]
public const uint NV_CTRL_GPU_CORE_TEMPERATURE;
public const uint NV_CTRL_GPU_CURRENT_CLOCK_FREQS;
public const uint NV_CTRL_TOTAL_GPU_MEMORY;
public const uint NV_CTRL_STRING_GPU_UTILIZATION;
public const uint NV_CTRL_USED_DEDICATED_GPU_MEMORY;
public const uint NV_CTRL_GPU_CURRENT_PROCESSOR_CLOCK_FREQS;
public const int NV_CTRL_TARGET_TYPE_GPU;
