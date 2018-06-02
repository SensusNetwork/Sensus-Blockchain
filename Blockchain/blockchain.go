/ Package blockchain provides the tools for encoding
// data primitives in blockchain structures
package blockchain

import (
	"encoding/binary"
	"errors"
	"io"
	"math"
	"sync"

	"chain/encoding/bufpool"
)

var bufPool = sync.Pool{New: func() interface{} { return new([9]byte) }}

var ErrRange = errors.New("value out of range")

// Reader wraps a buffer and provides utilities for decoding
// data primitives in blockchain structures. Its various read
// calls may return a slice of the underlying buffer.
type Reader struct {
	buf []byte
}
