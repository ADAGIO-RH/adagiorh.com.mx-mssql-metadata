USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca conceptos por IDConcepto, Codigo o todos los registros
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
2024-10-03		JOSE ROMAN			SE AGREGA COLUMNA DE PRESUPUESTO BIT
***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spBuscarCatConceptos]
(
	@IDConcepto int = null,
	@Codigo varchar(20) = null
)
AS
BEGIN
	SELECT  
	    c.IDConcepto
	   ,c.Codigo
	   ,c.Descripcion
	   ,c.IDTipoConcepto
	   ,tp.Descripcion as TipoConcepto
	   ,c.Estatus
	   ,c.Impresion
	   ,c.IDCalculo
	   ,tcISR.Descripcion as TipoCalculoISR
	   ,c.CuentaAbono
	   ,c.CuentaCargo
	   ,c.bCantidadMonto
	   ,c.bCantidadDias
	   ,c.bCantidadVeces
	   ,c.bCantidadOtro1
	   ,c.bCantidadOtro2
	   ,isnull(c.IDCodigoSAT,0) IDCodigoSAT
	   ,isnull(cSAT.Codigo +' - '+ cSAT.Descripcion,'CONCEPTO') as CodigoSAT
	   ,c.NombreProcedure
	   ,c.OrdenCalculo
	   ,c.LFT
	   ,c.Personalizada
	   ,c.ConDoblePago
	   ,isnull(c.IDPais,0) as IDPais
	   ,isnull(c.Presupuesto,0) as Presupuesto
	   ,p.Descripcion as Pais
	FROM Nomina.tblCatConceptos c with(nolock)
	 join Nomina.tblCatTipoConcepto tp with(nolock) 
		on c.IDTipoConcepto = tp.IDTipoConcepto
	 join Nomina.tblCatTipoCalculoISR tcISR with(nolock) 
		on c.IDCalculo = tcISR.IDCalculo
	 left join ( select IDTipoDeduccion as ID, Codigo, Descripcion,2 as Tipo
			   from Sat.tblCatTiposDeducciones with(nolock)
			   UNION
				   select IDTipoPercepcion as ID, Codigo, Descripcion,1 as Tipo
				   from Sat.tblCatTiposPercepciones with(nolock)
			   UNION
				   select IDTipoOtroPago as ID, Codigo, Descripcion,4 as Tipo
				   from Sat.tblCatTiposOtrosPagos with(nolock)
				UNION
				select IDTipoDeduccion as ID, Codigo, Descripcion,8 as Tipo
				from Sat.tblCatTiposDeducciones
				UNION
				select IDTipoPercepcion as ID, Codigo, Descripcion,7 as Tipo
				from Sat.tblCatTiposPercepciones
				UNION
				select IDTipoOtroPago as ID, Codigo, Descripcion,10 as Tipo
				from Sat.tblCatTiposOtrosPagos
		) as cSAT 
			on ((c.IDCodigoSAT = cSAT.ID) 
				and (cSAT.Tipo = tp.IDTipoConcepto))
	 left join Sat.tblCatPaises p with(nolock)
		on c.IDPais = p.IDPais
	where (c.IDConcepto = @IDConcepto or @IDConcepto is null)
		  and (c.Codigo = @Codigo or @Codigo is null)	
     order by c.OrdenCalculo asc
END
GO
