USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staffing].[tblCatStaff](
	[IDConfiguracion] [int] IDENTITY(1,1) NOT NULL,
	[IDSucursal] [int] NULL,
	[IDPuesto] [int] NULL,
	[Porcentaje] [int] NULL,
	[Cantidad] [int] NULL,
 CONSTRAINT [Pk_StaffingTblCatStaffIDConfiguracion] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Staffing].[tblCatStaff]  WITH CHECK ADD  CONSTRAINT [FK_StaffingTblCatStaffRHtblCatPuestos_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
GO
ALTER TABLE [Staffing].[tblCatStaff] CHECK CONSTRAINT [FK_StaffingTblCatStaffRHtblCatPuestos_IDPuesto]
GO
ALTER TABLE [Staffing].[tblCatStaff]  WITH CHECK ADD  CONSTRAINT [FK_StaffingTblCatStaffRHtblCatSucursales_IDSucursal] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Staffing].[tblCatStaff] CHECK CONSTRAINT [FK_StaffingTblCatStaffRHtblCatSucursales_IDSucursal]
GO
