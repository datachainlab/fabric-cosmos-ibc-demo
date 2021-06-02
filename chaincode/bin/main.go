package main

import (
	"fmt"
	"io"
	"os"

	ccapp "github.com/datachainlab/fabric-cosmos-ibc-demo/chaincode/app"
	"github.com/datachainlab/fabric-ibc/app"
	"github.com/datachainlab/fabric-ibc/chaincode"
	"github.com/datachainlab/fabric-ibc/commitment"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	tmlog "github.com/tendermint/tendermint/libs/log"
	tmdb "github.com/tendermint/tm-db"
)

func main() {
	ibc := chaincode.NewIBCChaincode(
		// XXX chainid
		"ibc1",
		tmlog.NewTMLogger(os.Stdout),
		commitment.NewDefaultSequenceManager(),
		newApp,
		ccapp.DefaultAnteHandler,
		chaincode.DefaultDBProvider,
		chaincode.DefaultMultiEventHandler(),
	)
	cc, err := contractapi.NewChaincode(ibc)
	if err != nil {
		fmt.Printf("Error create IBC chaincode: %s", err.Error())
		return
	}

	server := &shim.ChaincodeServer{
		CCID:    os.Getenv("CHAINCODE_CCID"),
		Address: os.Getenv("CHAINCODE_ADDRESS"),
		CC:      cc,
		TLSProps: shim.TLSProperties{
			Disabled: true,
		},
	}
	if err = server.Start(); err != nil {
		fmt.Printf("Error starting IBC chaincode: %s", err)
	}
}

func newApp(appName string, logger tmlog.Logger, db tmdb.DB, traceStore io.Writer, seqMgr commitment.SequenceManager, blockProvider app.BlockProvider, anteHandlerProvider app.AnteHandlerProvider) (app.Application, error) {
	return ccapp.NewIBCApp(
		appName,
		logger,
		db,
		traceStore,
		ccapp.MakeEncodingConfig(),
		seqMgr,
		blockProvider,
		anteHandlerProvider,
	)
}
