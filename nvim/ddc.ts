import { BaseConfig } from "https://deno.land/x/ddc_vim@v4.3.1/types.ts";
import { ConfigArguments } from "https://deno.land/x/ddc_vim@v4.3.1/base/config.ts";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): Promise<void> {
    args.contextBuilder.patchGlobal({
      ui: "inline",
      sources: ["lsp", "around", "look"],
      autoCompleteEvents: [
        "InsertEnter",
        "TextChangedI",
        "TextChangedP",
      ],
      sourceOptions: {
        _: {
          matchers: ["matcher_fuzzy"],
          // sorters: ["sorter_rank"],
          converters: ["converter_remove_overlap"],
          minAutoCompleteLength : 1,
        },
        around: {
          enabledIf: "luaeval('vim.tbl_count(vim.lsp.get_clients()) == 0')",
        },
        look: {
          enabledIf: "luaeval('vim.tbl_count(vim.lsp.get_clients()) == 0')",
          matchers: [
              {
                name: "matcher_fuzzy",
                params: {splitMode: "char"}
              }
          ]
        },
        lsp: {
          forceCompletionPattern: "\\.\\w*|::\\w*|->\\w*",
          sorters: ["sorter_lsp-kind"],
          dup: "force",
        },
      },
      sourceParams: {
        lsp: {
          // snippetEngine: "vim.snippet", not implemented
          enableResolveItem: true,
          enableAdditionalTextEdit: true,
        },
            },
      // postFilters:["sorter_rank"],
      postFilters:["sorter_fuzzy"],
      filterParams: {
        matcher_fuzzy: {
          splitMode: "word",
        },
        "sorter_lsp-kind": {
          priority: [["Variable", "Text", "Method", "Function"]]
        },
      },
      backspaceCompletion: true,
    });
  }
}
