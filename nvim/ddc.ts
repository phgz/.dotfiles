import { BaseConfig } from "https://deno.land/x/ddc_vim@v3.5.1/types.ts";
import { ConfigArguments } from "https://deno.land/x/ddc_vim@v3.5.1/base/config.ts";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): Promise<void> {
    args.contextBuilder.patchGlobal({
      ui: "inline",
      sources: ["nvim-lsp", "around", "ultisnips", "file"],
      autoCompleteEvents: [
        "InsertEnter",
        "TextChangedI",
        "TextChangedP",
        "CmdlineEnter",
        "CmdlineChanged",
        "TextChangedT",
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
          enabledIf: "luaeval('vim.tbl_count(vim.lsp.get_active_clients()) == 0')",
        },
        file: {
          mark: "F",
          forceCompletionPattern: "\\S/\\S*",
        },
        "nvim-lsp": {
          mark: "LSP",
          forceCompletionPattern: "\\.\\w*|::\\w*|->\\w*",
          dup: "force",
        },
        ultisnips: {
          mark: "U",
        },
      },
      sourceParams: {
        "nvim-lsp": {
          enableResolveItem: true,
          enableAdditionalTextEdit: true,
        },
            },
      filterParams: {
        matcher_fuzzy: {
          splitMode: "word",
        },
      },
      backspaceCompletion: true,
    });
  }
}
