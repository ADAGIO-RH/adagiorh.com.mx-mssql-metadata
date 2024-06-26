USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS LECTORES
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-10-20			Aneudy Abreu	Se agregaron los campos IDCliente y Cliente
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spBuscarLectores]
(
	@IDLector int = null
)
AS
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
		,isnull(l.EsComedor,0) as EsComedor
		,isnull(l.Comida,0) as Comida
		,isnull(L.IDCliente,0) IDCliente
		,isnull(c.NombreComercial,'Sin cliente asignado') as Cliente
		,ROW_NUMBER()OVER(ORDER BY IDLECTOR ASC) AS ROWNUMBER
	from Asistencia.tblLectores L
		INNER JOIN Asistencia.tblCatTiposLectores TL
			on L.IDTipoLector = TL.IDTipoLector
		LEFT JOIN RH.tblCatClientes c on c.IDCliente = L.IDCliente
		LEFT JOIN Tzdb.Zones Z
			on Z.Id = L.IDZonaHoraria
	WHERE ((IDLector = @IDLector) OR (@IDLector IS NULL))
END
GO
