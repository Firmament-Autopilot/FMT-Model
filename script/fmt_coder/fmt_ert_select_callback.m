function fmt_ert_select_callback(hDlg, hSrc)
    slConfigUISetVal(hDlg, hSrc, 'GenCodeOnly', 'off');
    slConfigUISetVal(hDlg, hSrc, 'GenerateMakefile', 'off');
    slConfigUISetVal(hDlg, hSrc, 'GenerateSampleERTMain', 'off');
    slConfigUISetVal(hDlg, hSrc, 'CodeReplacementLibrary', 'STM32 DSP LIB');
    slConfigUISetVal(hDlg, hSrc, 'UtilityFuncGeneration', 'Shared location');
    slConfigUISetVal(hDlg, hSrc, 'ProdIntDivRoundTo', 'Zero');
    slConfigUISetVal(hDlg, hSrc, 'TargetIntDivRoundTo', 'Zero');
end
