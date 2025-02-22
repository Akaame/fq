# TODO: error value preview
def _expected_decode_value:
  error("expected a decode value but got: \(. | type) (\(. | tostring))");
# TODO: helper? _is_decode_value?
def _decode_value(f; ef):
  if _is_decode_value then f
  else ef
  end;
def _decode_value(f): _decode_value(f; _expected_decode_value);

# null input means done, otherwise {approx_read_bytes: 123, total_size: 123}
# TODO: decode provide even more detailed progress, post-process sort etc?
def _decode_progress:
  # _input_filenames is remaning files to read
  ( (_input_filenames | length) as $inputs_len
  | ( options.filenames | length) as $filenames_len
  | _ansi.clear_line
  , "\r"
  , if . != null then
      ( if $filenames_len > 1 then
          "\($filenames_len - $inputs_len)/\($filenames_len) \(_input_filename) "
        else empty
        end
      , "\((.approx_read_bytes / .total_size * 100 | _numbertostring(1)))%"
      )
    else empty
    end
  | printerr
  );

def decode($name; $decode_opts):
  ( options as $opts
  | _decode(
      $name;
      $opts +
      {
        _progress: (
          if $opts.decode_progress and $opts.repl and stdout_tty.is_terminal then
            "_decode_progress"
          else null
          end
        ),
      } +
      $decode_opts
    )
  );
def decode($name): decode($name; {});
def decode: decode(options.decode_format; {});

def topath: _decode_value(._path);
def tovalue($opts): _tovalue(options($opts));
def tovalue: _tovalue({});
def toactual: _decode_value(._actual);
def tosym: _decode_value(._sym);
def todescription: _decode_value(._description);

# TODO: rename?
def format: _decode_value(._format; null);

def root: _decode_value(._root);
def buffer_root: _decode_value(._buffer_root);
def format_root: _decode_value(._format_root);
def parent: _decode_value(._parent);
def parents:
  # TODO: refactor, _while_break?
  ( _decode_value(._parent)
  | if . == null then empty
    else
      _recurse_break(
        ( ._parent
        | if . == null then error("break") end
        )
      )
    end
  );

def in_bits_range($p):
  select(._start <= $p and $p < ._stop);
def in_bytes_range($p):
  select(._start/8 <= $p and $p < ._stop/8);
