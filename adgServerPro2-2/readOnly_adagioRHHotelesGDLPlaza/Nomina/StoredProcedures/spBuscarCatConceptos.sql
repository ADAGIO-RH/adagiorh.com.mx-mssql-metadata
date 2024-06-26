USE [readOnly_adagioRHHotelesGDLPlaza]
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
	FROM Nomina.tblCatConceptos c
	 join Nomina.tblCatTipoConcepto tp on c.IDTipoConcepto = tp.IDTipoConcepto
	 
	 join Nomina.tblCatTipoCalculoISR tcISR on c.IDCalculo = tcISR.IDCalculo
	 left join ( select IDTipoDeduccion as ID, Codigo, Descripcion,2 as Tipo
			   from Sat.tblCatTiposDeducciones
			   UNION
			   select IDTipoPercepcion as ID, Codigo, Descripcion,1 as Tipo
			   from Sat.tblCatTiposPercepciones
			   UNION
			   select IDTipoOtroPago as ID, Codigo, Descripcion,4 as Tipo
			   from Sat.tblCatTiposOtrosPagos
	 ) as cSAT on ((c.IDCodigoSAT = cSAT.ID) and (cSAT.Tipo = tp.IDTipoConcepto))
	where (c.IDConcepto = @IDConcepto or @IDConcepto is null)
		  and (c.Codigo = @Codigo or @Codigo is null)	
     order by c.OrdenCalculo asc
END
GO
