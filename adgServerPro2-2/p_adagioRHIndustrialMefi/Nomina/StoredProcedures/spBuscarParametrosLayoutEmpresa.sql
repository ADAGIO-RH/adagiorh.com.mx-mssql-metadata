USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para Buscar los datos para llenar los Layouts por Empresa
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018--8-27
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE Nomina.spBuscarParametrosLayoutEmpresa --7 ,4
(
	@IDEmpresa int
)
AS
BEGIN
	
	SELECT elp.IDEmpresaLayoutParametro
		  ,elp.IDEmpresa
		  ,e.NombreComercial as Empresa
		  ,lp.IDLayoutParametro
		  ,lp.Parametro
		  ,isnull(elp.Valor,'') Valor
		  ,tl.IDTipoLayout
		  ,tl.TipoLayout as Layout
		  ,b.IDBanco
		  ,b.Descripcion as Banco
		FROM Nomina.tblEmpresaLayoutsParametros elp
			inner join RH.tblEmpresa e
				on elp.IDEmpresa = e.IdEmpresa
			inner join Nomina.tblCatLayoutParametros lp
				on elp.IDLayoutParametro = lp.IDLayoutParametro
			inner join Nomina.tblCatTiposLayout tl
				on tl.IDTipoLayout = lp.IDTipoLayout
			inner join sat.tblCatBancos b
				on tl.IDBanco = b.IDBanco
		where elp.IdEmpresa = @IDEmpresa
			
END
GO
