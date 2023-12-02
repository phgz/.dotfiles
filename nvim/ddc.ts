import { BaseConfig } from "https://deno.land/x/ddc_vim@v3.9.0/types.ts";
import { ConfigArguments } from "https://deno.land/x/ddc_vim@v3.9.0/base/config.ts";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): Promise<void> {
    args.contextBuilder.patchGlobal({
      ui: "inline",
      sources: ["lsp", "around", "file"],
      autoCompleteEvents: [
        "InsertEnter",
        "TextChangedI",
        "TextChangedP",
      ],
      sourceOptions: {
        _: {
          matchers: ["matcher_fuzzy"],
          sorters: ["sorter_fuzzy"],
          converters: ["converter_remove_overlap"],
          minAutoCompleteLength : 1,
        },
        around: {
          mark: "A",
          enabledIf: "luaeval('vim.tbl_count(vim.lsp.get_clients()) == 0')",
        },
        file: {
          mark: "F",
          forceCompletionPattern: "\\S/\\S*",
        },
        lsp: {
          mark: "LSP",
          forceCompletionPattern: "\\.\\w*|::\\w*|->\\w*",
          sorters: ["sorter_lsp-kind"],
          dup: "force",
        },
      },
      sourceParams: {
        "lsp": {
          snippetEngine: "vim.snippet",
          enableResolveItem: true,
          enableAdditionalTextEdit: true,
        },
            },
      filterParams: {
        matcher_fuzzy: {
          splitMode: "word",
        },
        "sorter_lsp-kind": {
          priority: [["Variable", "Text", "Method", "Function"]]
        }
      },
      backspaceCompletion: true,
    });
  }
}
