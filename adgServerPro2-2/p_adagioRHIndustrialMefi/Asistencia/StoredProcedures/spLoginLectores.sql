USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA LOGIN DE LECTORES
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spLoginLectores]
(
	@CodigoLector Varchar(MAX),
	@PasswordLector Varchar(MAX)
)
AS
BEGIN
	IF EXISTS(Select Top 1 1 
			from Asistencia.tblLectores 
			WHERE CodigoLector = @CodigoLector and PasswordLector = @PasswordLector 
	)
	BEGIN
		SELECT 
			 L.IDLector
			,L.Lector
			,L.CodigoLector
			,L.PasswordLector
			,L.IDTipoLector
			,TL.TipoLector
			,isnull(L.IDZonaHoraria,0) as IDZonaHoraria
			,isnull(z.Name,'SIN DEFINIR') as ZonaHoraria
			,l.IP as IP
			,l.Puerto as Puerto
			,l.Estatus as Estatus
			,cast( 1 as bit) as AccesoCorrecto
			,l.Configuracion
			,ROW_NUMBER()OVER(ORDER BY IDLECTOR ASC) AS ROWNUMBER
		from Asistencia.tblLectores L
			inner join Asistencia.tblCatTiposLectores TL on L.IDTipoLector = TL.IDTipoLector
			left join Tzdb.Zones Z on Z.Id = L.IDZonaHoraria
		WHERE L.CodigoLector = @CodigoLector and L.PasswordLector = @PasswordLector
	END
	ELSE
	BEGIN
		RAISERROR('Codigo o Password del lector Incorrectos',16,1);
	END
END
GO
