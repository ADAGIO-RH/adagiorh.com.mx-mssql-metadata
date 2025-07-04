USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Norma35].[spBuscarDenunciaByID]
	-- Add the parameters for the stored procedure here
	@IDDenuncia int,
	@IDUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	select	de.IDDenuncia            
			,denuncias.Descripcion as [TipoDenunciaDescripcion]  
            ,de.IDEstatusDenuncia 
            ,estd.EstatusColor
            ,estd.EstatusBackground 						
            ,estd.Descripcion as  [EstatusDescripcion]
            ,de.Justificacion
			,de.DescripcionHechosHtml 
            ,de.IDTipoDenunciado
            ,deno.Descripcion [TipoDenunciadoDescripcion]
            ,de.IDEmpleadoDenunciante 
			,EmpleadoDenunciante = (
				select 
					eD.IDEmpleado,
					eD.ClaveEmpleado,
					eD.NOMBRECOMPLETO as NombreCompleto,
					eD.Departamento,
					eD.Sucursal,
					eD.Puesto
				from RH.tblEmpleadosMaster eD
				where eD.IDEmpleado = de.IDEmpleadoDenunciante 
				for json auto, without_array_wrapper
			)
			,de.EsAnonima												
			,de.FechaEvento
			,de.FechaRegistro            
            ,de.Denunciados 
			,de.IDTipoDenuncia
			,de.DescripcionHechos
			,@IDUsuario as IDUsuario
	from Norma35.tblDenuncias as de	
		left join [Norma35].[tblCatEstatusDenuncia] as estd on estd.IDEstatusDenuncia=de.IDEstatusDenuncia
		left join Norma35.tblCatTiposDenunciado deno on deno.IDTipoDenunciado=de.IDTipoDenunciado  	
		left join Norma35.tblCatTiposDenuncias denuncias on denuncias.IDTipoDenuncia=de.IDTipoDenuncia
	WHERE de.IDDenuncia= @IDDenuncia
	 

END
GO
