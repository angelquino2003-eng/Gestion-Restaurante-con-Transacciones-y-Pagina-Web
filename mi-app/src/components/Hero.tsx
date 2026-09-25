import LogoImg from "../assets/Logo.jpg"
export default function Hero() {
  return (
    <section className="hero">
      <div>
        <h1>Cocina criolla y marina. El mejor sazón de todo Lima</h1>
        <p>
          Elija sus platos del día, tenemos variedad para todo tipo de gustos. 
          No se lo pierda.
        </p>
        <div className="hero-meta">
          <div><strong>25–35 min</strong>tiempo de preparación</div>
          <div><strong>S/ 10</strong>consumo mínimo delivery</div>
          <div><strong>4.8</strong>valoración de comensales</div>
        </div>
      </div>

      <div className="hero-art">
        <img src={LogoImg}></img>
      </div>
    </section>
  );
}