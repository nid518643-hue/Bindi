index.html
import React, { useState, useEffect, createContext, useContext } from "react";
import "./App.css";

/* === CONTEXT === */
const GameContext = createContext();

function GameProvider({ children }) {
  const load = (key, def) => {
    const val = localStorage.getItem(key);
    return val ? JSON.parse(val) : def;
  };

  const [money, setMoney] = useState(load("money", 1000));
  const [xp, setXp] = useState(load("xp", 0));
  const [level, setLevel] = useState(load("level", 1));
  const [clickPower, setClickPower] = useState(load("clickPower", 1));
  const [upgrades, setUpgrades] = useState(load("upgrades", {}));

  const addMoney = (amount) => {
    setMoney((prev) => prev + amount);
    setXp((prev) => prev + amount * 0.2);
  };

  const buyUpgrade = (id, cost, bonus) => {
    if (money >= cost && !upgrades[id]) {
      setMoney(money - cost);
      setClickPower((prev) => prev + bonus);
      setUpgrades({ ...upgrades, [id]: true });
    }
  };

  const levelUp = () => {
    while (xp >= level * 100) {
      setLevel((prev) => prev + 1);
      setXp((prev) => prev - level * 100);
    }
  };

  useEffect(() => localStorage.setItem("money", JSON.stringify(money)), [money]);
  useEffect(() => localStorage.setItem("xp", JSON.stringify(xp)), [xp]);
  useEffect(() => localStorage.setItem("level", JSON.stringify(level)), [level]);
  useEffect(() => localStorage.setItem("clickPower", JSON.stringify(clickPower)), [clickPower]);
  useEffect(() => localStorage.setItem("upgrades", JSON.stringify(upgrades)), [upgrades]);
  useEffect(() => levelUp(), [xp]);

  // Автокликер каждые 1 сек
  useEffect(() => {
    const interval = setInterval(() => addMoney(clickPower), 1000);
    return () => clearInterval(interval);
  }, [clickPower]);

  return (
    <GameContext.Provider value={{ money, xp, level, clickPower, upgrades, addMoney, buyUpgrade }}>
      {children}
    </GameContext.Provider>
  );
}

/* === APP === */
function App() {
  const [page, setPage] = useState("menu");

  const renderPage = () => {
    switch (page) {
      case "auto": return <AutoClicker />;
      case "shop": return <Shop />;
      case "profile": return <Profile />;
      case "mines": return <Mines />;
      case "crash": return <Crash100 />;
      case "aviator": return <Aviator />;
      case "roulette": return <Roulette />;
      case "wheel": return <Wheel />;
      case "fish": return <Fishing />;
      case "league": return <League />;
      default: return menu();
    }
  };

  const menu = () => (
    <div className="menu">
      <h1 className="title">Bindi_tm</h1>
      <div className="grid">
        <button onClick={() => setPage("auto")}>Автокликер</button>
        <button onClick={() => setPage("mines")}>Мины</button>
        <button onClick={() => setPage("crash")}>Crash x100</button>
        <button onClick={() => setPage("aviator")}>Авиатор</button>
        <button onClick={() => setPage("roulette")}>Рулетка</button>
        <button onClick={() => setPage("wheel")}>Колесо фортуны</button>
        <button onClick={() => setPage("fish")}>Рыбалка</button>
        <button onClick={() => setPage("shop")}>Магазин</button>
        <button onClick={() => setPage("profile")}>Профиль</button>
        <button onClick={() => setPage("league")}>Лига игроков</button>
      </div>
      <footer className="footer">by Bindi</footer>
    </div>
  );

  return (
    <GameProvider>
      <div className="app">{renderPage()}</div>
    </GameProvider>
  );
}

/* === COMPONENTS === */

function AutoClicker() {
  const { money, clickPower, addMoney } = useContext(GameContext);
  return (
    <div className="page">
      <h1>Автокликер</h1>
      <div className="card">
        <h2>Баланс: {money} 💰</h2>
        <h3>Сила клика: {clickPower}</h3>
        <button onClick={() => addMoney(clickPower * 2)}>Нажми для монет</button>
      </div>
    </div>
  );
}
function Shop() {
  const { money, clickPower, buyUpgrade, upgrades } = useContext(GameContext);
  const items = [
    { id: "u1", name: "Клик x2", cost: 500, bonus: 1 },
    { id: "u2", name: "Клик x5", cost: 2000, bonus: 5 },
    { id: "u3", name: "Автоклик PRO", cost: 10000, bonus: 15 },
    { id: "u4", name: "Фиолетовый бафф", cost: 25000, bonus: 30 }
  ];
  return (
    <div className="page">
      <h1>Магазин</h1>
      <h2>Баланс: {money}</h2>
      <div className="shop-grid">
        {items.map(i => (
          <div key={i.id} className="shop-item">
            <h3>{i.name}</h3>
            <p>Цена: {i.cost}</p>
            <button disabled={upgrades[i.id]} onClick={() => buyUpgrade(i.id, i.cost, i.bonus)}>
              {upgrades[i.id] ? "Куплено" : "Купить"}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

function Profile() {
  const { money, level, xp } = useContext(GameContext);
  return (
    <div className="page">
      <h1>Профиль</h1>
      <div className="card">
        <h2>Баланс: {money} 💰</h2>
        <h2>Уровень: {level}</h2>
        <h2>Опыт: {xp}</h2>
        <div className="xp-bar">
          <div className="xp-fill" style={{width:${(xp/(level*100))*100}%}}></div>
        </div>
      </div>
    </div>
  );
}

/* === Mines === */
function Mines() {
  const { money, addMoney } = useContext(GameContext);
  const [bet, setBet] = useState(100);
  const [mines] = useState(5);
  const [grid, setGrid] = useState(Array(25).fill(null));
  const [active, setActive] = useState(false);
  const [hits, setHits] = useState(0);

  const start = () => {
    if(bet>money) return;
    setActive(true);
    setGrid(Array(25).fill(null));
    setHits(0);
  }

  const pick = (i) => {
    if(!active) return;
    const isMine = Math.random()<mines/25;
    if(isMine) { setGrid(g=>g.map((v,idx)=>(idx===i?"💣":v))); setActive(false); }
    else { setGrid(g=>g.map((v,idx)=>(idx===i?"💎":v))); setHits(h=>h+1); }
  }

  const cashout = () => { addMoney(bet*(1+hits*0.35)); setActive(false); }

  return (
    <div className="page">
      <h1>Мины</h1>
      <div className="card">
        <p>Баланс: {money}</p>
        <input type="number" value={bet} onChange={e=>setBet(Number(e.target.value))} />
        <button onClick={start}>Начать</button>
        <button onClick={cashout}>Забрать</button>
      </div>
      <div className="mines-grid">
        {grid.map((c,i)=><div key={i} className="mines-cell" onClick={()=>pick(i)}>{c}</div>)}
      </div>
    </div>
  );
}

/* === Crash x100 === */
function Crash100() {
  const { money, addMoney } = useContext(GameContext);
  const [bet,setBet] = useState(100);
  const [mult,setMult] = useState(1);
  const [crash,setCrash] = useState(null);
  const [running,setRunning] = useState(false);

  useEffect(()=>{
    let interval;
    if(running){
      interval = setInterval(()=>{
        setMult(m=>m+0.03);
        if(mult>=crash) setRunning(false);
      },100);
    }
    return ()=>clearInterval(interval);
  },[running,mult,crash]);

  const start=()=>{
    if(bet>money) return;
    setCrash(Number((Math.random()*99+1).toFixed(2)));
    setMult(1);
    setRunning(true);
  }

  const cashout=()=>{
    if(!running) return;
    addMoney(bet*mult);
    setRunning(false);
  }

  return (
    <div className="page">
      <h1>Crash x100</h1>
      <div className="card">
        <p>Баланс: {money}</p>
        <input type="number" value={bet} onChange={e=>setBet(Number(e.target.value))}/>
        <button onClick={start}>Играть</button>
        <button onClick={cashout}>Забрать</button>
        <h2>Множитель: x{mult.toFixed(2)}</h2>
        {!running && crash && <h3 className="lose-text">Упал на x{crash}</h3>}
      </div>
    </div>
  );
}

/* === Aviator === */
function Aviator(){
  const { money, addMoney } = useContext(GameContext);
  const [bet,setBet]=useState(100);
  const [fly,setFly]=useState(1);
  const [limit,setLimit]=useState(null);
  const [running,setRunning]=useState(false);
useEffect(()=>{
    let interval;
    if(running){
      interval=setInterval(()=>{
        setFly(f=>f+0.02);
        if(fly>=limit) setRunning(false);
      },100)
    }
    return ()=>clearInterval(interval);
  },[running,fly,limit]);

  const start=()=>{
    if(bet>money) return;
    setLimit(Number((Math.random()*7+1).toFixed(2)));
    setFly(1);
    setRunning(true);
  }

  const cashout=()=>{
    if(!running) return;
    addMoney(bet*fly);
    setRunning(false);
  }

  return (
    <div className="page">
      <h1>Авиатор</h1>
      <div className="card">
        <p>Баланс: {money}</p>
        <input type="number" value={bet} onChange={e=>setBet(Number(e.target.value))}/>
        <button onClick={start}>Старт</button>
        <button onClick={cashout}>Забрать</button>
        <h2>Самолёт: x{fly.toFixed(2)}</h2>
        {!running && limit && <h4 className="lose-text">Самолёт улетел x{limit}</h4>}
      </div>
    </div>
  )
}

/* === Roulette === */
function Roulette(){
  const { money, addMoney } = useContext(GameContext);
  const [bet,setBet]=useState(100);
  const [choice,setChoice]=useState("red");
  const [res,setRes]=useState(null);

  const spin=()=>{
    if(bet>money) return;
    const colors=["red","black","green"];
    const roll=colors[Math.floor(Math.random()*37)];
    setRes(roll);
    if(roll===choice){ addMoney(choice==="green"?bet*14:bet*2);}
  }

  return(
    <div className="page">
      <h1>Рулетка</h1>
      <div className="card">
        <p>Баланс: {money}</p>
        <input type="number" value={bet} onChange={e=>setBet(Number(e.target.value))}/>
        <select value={choice} onChange={e=>setChoice(e.target.value)}>
          <option value="red">Красное</option>
          <option value="black">Чёрное</option>
          <option value="green">Зелёное x14</option>
        </select>
        <button onClick={spin}>Крутить</button>
        {res && <h2>Выпало: <span className={res}>{res}</span></h2>}
      </div>
    </div>
  )
}

/* === Wheel === */
function Wheel(){
  const { addMoney } = useContext(GameContext);
  const [angle,setAngle]=useState(0);
  const [prize,setPrize]=useState(null);
  const sectors=[50,100,200,0,500,1000];

  const spin=()=>{
    const newAngle=angle+720+Math.random()*360;
    setAngle(newAngle);
    setTimeout(()=>{
      const idx=Math.floor(((newAngle%360)/360)*sectors.length);
      const win=sectors[idx];
      setPrize(win);
      addMoney(win);
    },3000);
  }

  return(
    <div className="page">
      <h1>Колесо фортуны</h1>
      <div className="wheel-box">
        <div className="wheel" style={{transform:rotate(${angle}deg)}}>
          {sectors.map((s,i)=><div key={i} className="sector">x{s}</div>)}
        </div>
      </div>
      <button onClick={spin}>Крутить</button>
      {prize!==null && <h2>Вы выиграли: {prize}</h2>}
    </div>
  )
}

/* === Fishing === */
function Fishing(){
  const { addMoney } = useContext(GameContext);
  const [fish,setFish]=useState(null);
  const fishes=[
    {name:"Треска", multi:1.2},
    {name:"Карп", multi:1.5},
    {name:"Щука", multi:2},
    {name:"Сом", multi:3},
    {name:"Золотая рыбка", multi:10}
  ];
  const catchFish=()=>{
    const f=fishes[Math.floor(Math.random()*fishes.length)];
    setFish(f);
    addMoney(100*f.multi);
  }

  return(
    <div className="page">
      <h1>Рыбалка</h1>
      <button onClick={catchFish}>Закинуть удочку</button>
      {fish && <h2>Поймали: {fish.name}! Множитель x{fish.multi}</h2>}
    </div>
  )
}

/* === League === */
function League(){
  const { level } = useContext(GameContext);
  const league=level<10?"Бронза":level<20?"Серебро":level<35?"Золото":level<50?"Платина":"Алмаз";
  return(
    <div className="page">
      <h1>Лига игроков</h1>
      <h2>Твоя лига: {league}</h2>
    </div>
  )
}

export default App;
