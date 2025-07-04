USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para Actualizar los datos para llenar los Layouts por Empresa
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-8-27
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE Nomina.spUParametrosLayoutEmpresa 
(
	@IDEmpresaLayoutParametro int,
	@Valor Varchar(255) = '',
	@IDUsuario int
)
AS
BEGIN

	update Nomina.tblEmpresaLayoutsParametros
		set Valor = @Valor
	Where IDEmpresaLayoutParametro = @IDEmpresaLayoutParametro
			
END
GO
