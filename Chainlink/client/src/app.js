import React, { Component, Fragment} from 'react';

import Web3, { Contract } from './utils/web3';

import Styles, { Button, Card, Content, Input } from './components';
import { H2, Strong, Small } from './components/typo';

// import MyComponent from './utils/wallet/wallet.js';

class App extends Component {
  state = {
    contractLoaded: false,
    isLoading: true,
    account: '',
    contract: {
      balance: '',
      manager: '',
      winner: '',
      players: []
    },
    amount: ''
  };


  componentDidMount = async () => {
    await this.handleFetchContract();
  }

  handleLoading = async () => {
    await this.setState(prevState => ({
      isLoading: !prevState.isLoading
    }))
  }

  handleChange = async (event) => {
    const amount = event.target.value;
    await this.setState({
      amount
    })
  }

  handleFetchContract = async () => {

    const accounts = await Web3.eth.getAccounts();
    const balance = await Web3.eth.getBalance(Contract._address);
    const manager = await Contract.methods.governance;
    const players = await Contract.methods.player_count().call();
    this.setState({
      account: accounts[0],
      contract: {
        balance,
        manager,
        players
      }
    });
    this.handleLoading();
    if (!this.state.contractLoaded) {
      this.setState({
        contract: {
          manager: Contract.methods.governance
        }
      });
      this.state.contractLoaded = true;
    }
  }

  handleOnSubmit = async event => {
    var ticketPrice = 0.02;
    var tickets = this.state.amount;
    var price = (tickets * ticketPrice).toString()
    event.preventDefault();
    this.handleLoading();
    const { account} = this.state;
    await Contract.methods.enter().send({
      from: account,
      value: Web3.utils.toWei(price, 'ether'),
      gas: '1000000'
    });
    await this.handleFetchContract();
  };


  handleOnPickWinner = async () => {
    this.handleLoading();
    const accounts = await Web3.eth.getAccounts();
    await Contract.methods.pickWinner().send({
      from: accounts[0]
    });
    const winner = await Contract.methods.winner().call();
    this.setState({
      contract: {
        winner
      }
    });
    this.handleFetchContract();
  };
  handleConnectToWallet = async () => {

    this.handleLoading();
    if (!this.state.contractLoaded) {
      this.loadContract();
    }
    const ethereum = window.ethereum;
    if(ethereum){
      ethereum.request({ method: 'eth_requestAccounts' })
      .then(accounts => {
        this.setState({
          account: accounts[0]
        });
      })
    }else{
      console.log('No ethereum browser detected');
    }
    this.handleFetchContract();
    
  };
  renderConnectWallet = () => {

    const { account} = this.state;
    return(
      account === "" && <Button type="button" onClick={this.handleConnectToWallet}>Connect to my wallet</Button>
    );
  }
  renderManager = () => {

    //const { contract } = this.state;
    return(
      <H2>
          This is your address
          <br/>
          { this.state.contract.manager }
      </H2>
    );
  }

  renderStatus = () => {
    const { account, contract } = this.state;
    const currentAccount = account || 'Your address is not available now';
    const playersCount = contract.players ? Contract.player_count : 0;
    const contractBalance = contract.balance ? Web3.utils.fromWei(contract.balance, 'ether') : 0;
    return(
      <div>
        <p>{ currentAccount }</p>
        <hr/>
        There are currently
        <br/>
        <Strong>{ playersCount }</Strong>
        <br/>
        <Small>Players</Small>
        <br/>
        Competing to win
        <br/>
        <Strong>{ contractBalance } </Strong>
        <br/>
        <Small>ETH</Small>
      </div>
    )
  }

  renderForm = () => {
    const { account, amount } = this.state;
    if (account !== "") {
      return(
        <form onSubmit={this.handleOnSubmit}>
            <Small>Maybe it's your lucky day! Buy a ticket!</Small>
            <br/>
            <Small>(One ticket costs 0.02 ETH)</Small>
            <Input type="number" step="0.001" value={amount} onChange={this.handleChange} placeholder="How much?" />
          <Button type="submit">I'll join!</Button>
        </form>
      )
    }
  }

  renderPickWinner = () => {
    const { account, contract } = this.state;
    return(
      account === contract.governance && <Button type="button" onClick={this.handleOnPickWinner}>Pick a WINNER!</Button>
    )
  }

  renderWinner = () => {
    const { contract } = this.state;
    return(
      contract.winner ? (
        alert(`Congrats, ${contract.winner} is the winner! :D`)
      ) : false
    )
  }

  loadContract = () => {
    this.setState({
      contractLoaded: true,
      contract: {
        manager: Contract.governance
      }
    })
  }

  render = () => {
    //const { isLoading } = this.state;
    //console.log(Contract.methods.governance().call());

    return (
      <Fragment>
        <Styles/>
        <Card>
            <Content>
              { this.renderConnectWallet() }
              { this.renderManager() }
              { this.renderStatus() }
              { this.renderForm() }
              { this.renderPickWinner() }
              { this.renderWinner() }
            </Content>
        </Card>
      </Fragment>
    );
  }
}

export default App;
