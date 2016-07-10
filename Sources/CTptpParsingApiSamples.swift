import CTptpParsing

struct CTptpParsingApiSamples {
  static func printTypes() {
    print("=========================================================")

    print("*** 'PrlcParser.h' ***")
    print("--- 'PrlcLexer.l' ---")

    print("prlc_lineno :",prlc_lineno.dynamicType,"// int prlc_lineno;")
    print("prlc_leng :",prlc_leng.dynamicType,"// unsigned long prlc_leng;")
    print("prlc_text :", prlc_text.dynamicType, "// char * _Nullable prlc_text;")
    print("prlc_in :", prlc_in.dynamicType, "// FILE * _Nullable prlc_in;")
    //print("prlc_output :", prlc_output.dynamicType)
    print("prlc_lex :", prlc_lex.dynamicType,"// int prlc_lex(void);")
    print("prlc_restart :", prlc_restart.dynamicType,"// void prlc_restart(FILE * _Nullable file);")

    print("--- 'PrlcParser.y' ---")
    print("prlc_parse :", prlc_parse.dynamicType,"// int prlc_parse(void);")
    print("prlc_error :", prlc_error.dynamicType,"// int prlc_error (const char * _Nullable s);")

    print("=========================================================")
    print("*** 'PrlcData.h' ***")
    print("prlcDestroyStore :", prlcDestroyStore.dynamicType)
    print("prlcStoreNodeFile :", prlcStoreNodeFile.dynamicType)




    print("=========================================================")




    print("prlcDestroyStore :", prlcDestroyStore.dynamicType)
    print("prlcStoreNodeFile :", prlcStoreNodeFile.dynamicType)



    print("prlcParsingRoot :",prlcParsingStore.dynamicType)
    print("prlcParsingRoot :",prlcParsingRoot.dynamicType)
    print("prlc_in :", prlc_in.dynamicType)
    print("prlc_lineno :", prlc_lineno.dynamicType)
    print("prlc_restart :", prlc_restart.dynamicType)
    print("prlc_parse :", prlc_parse.dynamicType)
    print("prlcCreateStore :", prlcCreateStore.dynamicType)
    print("prlcDestroyStore :", prlcDestroyStore.dynamicType)
    print("prlcStoreNodeFile :", prlcStoreNodeFile.dynamicType)

  }

}
